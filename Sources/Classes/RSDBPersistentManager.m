//
//  DBPersistentManager.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSDBPersistentManager.h"
#import "RSLogger.h"

int const RS_DB_Version = 2;
int const DEFAULT_STATUS_VALUE = 0;
static id lockObj;
NSString* _Nonnull const TABLE_EVENTS = @"events";
NSString* _Nonnull const COL_ID = @"id";
NSString* _Nonnull const COL_MESSAGE = @"message";
NSString* _Nonnull const COL_UPDATED = @"updated";
NSString* _Nonnull const COL_STATUS = @"status";
NSString* _Nonnull const TABLE_EVENTS_TO_DESTINATION = @"events_to_destination";
NSString* _Nonnull const COL_EVENT_ID = @"event_id";
NSString* _Nonnull const COL_DESTINATION_ID = @"destination_id";

@implementation RSDBPersistentManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDB];
        lockObj =  [[NSObject alloc] init];
    }
    return self;
}

- (void)createDB {
    if (sqlite3_open_v2([RSUtils getDBPath], &(self->_database), SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK) {
        // opened correctly
    }
}

// checks the events table for status column and would add the column, if missing.
// Migration is needed when an application is updated to the latest version of SDK from a version which doesn't has the status column in its events table
- (void)checkForMigrations {
    [RSLogger logDebug:@"RSDBPersistentManager: checkForMigrations: checking if the event table has status column"];
    if(![self checkIfStatusColumnExists]) {
        [RSLogger logDebug:@"RSDBPersistentManager: checkForMigrations: events table doesn't has the status column performing migration"];
        [self performMigration];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: checkForMigrations: event table has status column, no migration required"];
}

- (BOOL) checkIfStatusColumnExists {
    NSString* checkIfStatusExistsSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) from pragma_table_info(%@) where name=\"%@\";", TABLE_EVENTS, COL_STATUS];
    const char* statusCheckSQL = [checkIfStatusExistsSQLString UTF8String];
    sqlite3_stmt *statusCheckStmt = nil;
    BOOL statusColumnExists = NO;
    if (sqlite3_prepare_v2(self->_database, statusCheckSQL, -1, &statusCheckStmt, nil) == SQLITE_OK) {
        if(sqlite3_step(statusCheckStmt) == SQLITE_ROW) {
            int count = sqlite3_column_int(statusCheckStmt, 0);
            if(count > 0) {
                statusColumnExists = YES;
            }
        }
        else {
            [RSLogger logWarn:@"RSDBPersistentManager: checkIfStatusColumnExists: SQLite Command Execution Failed"];
        }
    }
    else {
        [RSLogger logError:@"RSDBPersistentManager: checkIfStatusColumnExists: SQLite Command Preparation Failed"];
    }
    sqlite3_finalize(statusCheckStmt);
    return statusColumnExists;
}

- (void) performMigration {
    NSString* alterTableSQLString = [[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER DEFAULT %d;", TABLE_EVENTS, COL_STATUS, DEFAULT_STATUS_VALUE];
    NSString* updateTableSQLString = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %d;", TABLE_EVENTS, COL_STATUS, DEVICEMODEPROCESSINGDONE];
    
    if([self execSQL:alterTableSQLString] && [self execSQL:updateTableSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: performMigration: events table migrated to add status column"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: performMigration: events table migration failed"];
}

- (void)createTables {
    [self createEventsTableWithVersion:RS_DB_Version];
    [self createEventsToDestinationIdMappingTable];
}

-(void) createEventsTableWithVersion:(int) version {
    NSString *createTableSQLString;
    switch(version) {
        case 1:
            createTableSQLString = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ TEXT NOT NULL, %@ INTEGER NOT NULL);", TABLE_EVENTS, COL_ID, COL_MESSAGE, COL_UPDATED];
            break;
        default:
            createTableSQLString = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ TEXT NOT NULL, %@ INTEGER NOT NULL, %@ INTEGER DEFAULT %d);", TABLE_EVENTS, COL_ID, COL_MESSAGE, COL_UPDATED, COL_STATUS, DEFAULT_STATUS_VALUE];
    }
    
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: createEventsTableWithVersion: Schema: %@", createTableSQLString]];
    if([self execSQL:createTableSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: createEventsTableWithVersion: successfully created the table"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: createEventsTableWithVersion: failed to create the table"];
}

// table to hold the events to destination mapping, Eg: If event e1 needs to be sent to destinations d1 & d2, both of which needs transformations, then we would insert entries e1->d1 & e1->d2 in the following table
-(void) createEventsToDestinationIdMappingTable {
    NSString *createTableSQLString = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@( %@ INTEGER NOT NULL, %@ TEXT NOT NULL);", TABLE_EVENTS_TO_DESTINATION, COL_EVENT_ID, COL_DESTINATION_ID];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: createEventsToDestinationIdMappingTable: Schema: %@", createTableSQLString]];
    if([self execSQL:createTableSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: createEventsToDestinationIdMappingTable: successfully created the table"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: createEventsToDestinationIdMappingTable: failed to create the table"];
}



- (NSNumber*)saveEvent:(NSString *)message {
    NSString *insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@, %@) VALUES ('%@', %ld) RETURNING %@;", TABLE_EVENTS, COL_MESSAGE, COL_UPDATED, [message stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [RSUtils getTimeStampLong], COL_ID];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: saveEventSQL: %@", insertSQLString]];
    const char* insertSQL = [insertSQLString UTF8String];
    int rowId = -1;
    sqlite3_stmt *insertStmt = nil;
    if (sqlite3_prepare_v2(self->_database, insertSQL, -1, &insertStmt, nil) == SQLITE_OK) {
        if (sqlite3_step(insertStmt) == SQLITE_ROW) {
            // table created
            [RSLogger logDebug:@"RSDBPersistentManager: saveEvent: Successfully inserted event to table"];
            rowId = sqlite3_column_int(insertStmt, 0);
        } else {
            [RSLogger logError:@"RSDBPersistentManager: saveEvent: Failed to insert the event"];
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: saveEvent: SQLite Command Preparation Failed"];
    }
    sqlite3_finalize(insertStmt);
    return [NSNumber numberWithInt:rowId];
}

- (void)clearEventsFromDB:(NSMutableArray<NSString *> *)messageIds {
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ IN (%@);", TABLE_EVENTS, COL_ID, [RSUtils getCSVString:messageIds]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventSql: %@", deleteSqlString]];
    @synchronized (lockObj) {
    if([self execSQL:deleteSqlString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: clearEventsFromDB: Successfully deleted events from DB"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: clearEventsFromDB: Failed to delete events from DB"];
    }
}

-(RSDBMessage *)fetchEventsFromDB:(int)count ForMode:(MODES) mode {
    NSString* querySQLString = nil;
    switch(mode) {
        case CLOUDMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC LIMIT %d ;", TABLE_EVENTS, COL_STATUS, NOTPROCESSED, DEVICEMODEPROCESSINGDONE, COL_UPDATED, count];
            break;
        case DEVICEMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC LIMIT %d ;", TABLE_EVENTS, COL_STATUS, NOTPROCESSED, CLOUDMODEPROCESSINGDONE, COL_UPDATED, count];
            break;
        default:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC LIMIT %d;", TABLE_EVENTS, COL_UPDATED, count];
    }
    return [self getEventsFromDB:querySQLString];
}

-(RSDBMessage*) fetchAllEventsFromDBForMode:(MODES) mode {
    NSString* querySQLString = nil;
    switch(mode) {
        case CLOUDMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC ;", TABLE_EVENTS, COL_STATUS, NOTPROCESSED, DEVICEMODEPROCESSINGDONE, COL_UPDATED];
            break;
        case DEVICEMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC ;", TABLE_EVENTS, COL_STATUS, NOTPROCESSED, CLOUDMODEPROCESSINGDONE, COL_UPDATED];
            break;
        default:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC;", TABLE_EVENTS, COL_UPDATED];
    }
    return [self getEventsFromDB:querySQLString];
}

- (RSDBMessage *) getEventsFromDB :(NSString*) querySQLString {
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getEventsFromDB: fetchEventSql: %@", querySQLString]];
    const char* querySQL = [querySQLString UTF8String];
    NSMutableArray<NSString *> *messageIds = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *messages = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber *>* statuses = [[NSMutableArray alloc] init];
    
    @synchronized (lockObj) {
        sqlite3_stmt *queryStmt = nil;
        if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
            [RSLogger logDebug:@"RSDBPersistentManager: getEventsFromDB: Successfully fetched events from DB"];
            while (sqlite3_step(queryStmt) == SQLITE_ROW) {
                int messageId = sqlite3_column_int(queryStmt, 0);
                const unsigned char* queryResultCol1 = sqlite3_column_text(queryStmt, 1);
                int status = sqlite3_column_int(queryStmt,3);
                NSString *message = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
                [messageIds addObject:[[NSString alloc] initWithFormat:@"%d", messageId]];
                [messages addObject:message];
                [statuses addObject:[NSNumber numberWithInt:status]];
            }
        } else {
            [RSLogger logError:@"RSDBPersistentManager: getEventsFromDB: Failed to fetch events from DB"];
        }
    }
    
    RSDBMessage *dbMessage = [[RSDBMessage alloc] init];
    dbMessage.messageIds = messageIds;
    dbMessage.messages = messages;
    dbMessage.statuses = statuses;
    
    return dbMessage;
}

// If mode is passed as DEVICEMODE, this function would return the total number of events which were waiting for the Device Mode Processing to be done
- (int) getDBRecordCountForMode:(MODES) mode {
    NSString *countSQLString = nil;
    switch(mode) {
        case DEVICEMODE:
            countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ where %@ IN (%d,%d)", TABLE_EVENTS, COL_STATUS, NOTPROCESSED, DEVICEMODEPROCESSINGDONE];
            break;
        case CLOUDMODE:
            countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ where %@ IN (%d,%d)", TABLE_EVENTS, COL_STATUS, NOTPROCESSED, CLOUDMODEPROCESSINGDONE];
            break;
        default:
            countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@", TABLE_EVENTS];
    }
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getDBRecordCount: countSQLString: %@", countSQLString]];
    int count = 0;
    const char* countSQL = [countSQLString UTF8String];
    @synchronized (lockObj) {
    sqlite3_stmt *countStmt = nil;
    if (sqlite3_prepare_v2(self->_database, countSQL, -1, &countStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getDBRecordCount: Successfully fetched events count from DB"];
        while (sqlite3_step(countStmt) == SQLITE_ROW) {
            count = sqlite3_column_int(countStmt, 0);
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: getDBRecordCount: Failed to fetch events count from DB"];
    }
    }
    return count;
}

// need to synchronize
-(void) updateEventsWithIds:(NSArray*) messageIds withStatus:(EVENTPROCESSINGSTATUS) status {
    NSString *messageIdsCsv = [RSUtils getCSVString:messageIds];
    if(messageIdsCsv != nil) {
        NSString* updateEventStatusSQL = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %@ | %d WHERE %@ IN (%@);", TABLE_EVENTS, COL_STATUS, COL_STATUS, status, COL_ID, messageIdsCsv];
        @synchronized (lockObj) {
        if([self execSQL:updateEventStatusSQL]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: updateEventsStatus: Successfully updated the event status for events %@", messageIdsCsv]];
            return;
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: updateEventsStatus: Failed to update the status for events %@", messageIdsCsv]];
        }
    }
}

// need to synchronize
-(void) clearProcessedEventsFromDB {
    NSString* clearProcessedEventsSQL = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = %d", TABLE_EVENTS, COL_STATUS, COMPLETEPROCESSINGDONE];
    @synchronized (lockObj) {
    if([self execSQL:clearProcessedEventsSQL]){
        [RSLogger logDebug:@"RSDBPersistentManager: clearProcessedEventsFromDB: Successfully cleared the processed events from the db"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: clearProcessedEventsFromDB: Failed to clear the processed events from the db"];
    }
}

- (void)flushEventsFromDB {
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM %@", TABLE_EVENTS];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: flushEventsFromDB: deleteEventSql: %@", deleteSqlString]];
    if([self execSQL:deleteSqlString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: flushEventsFromDB: Successfully deleted events from DB"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: flushEventsFromDB: Failed to delete the events from DB"];
}

- (void) saveEvent:(NSNumber*) rowId toDestinationId:(NSString*) destinationId {
    NSString *insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@(%@, %@) VALUES (%d, '%@');", TABLE_EVENTS_TO_DESTINATION, COL_EVENT_ID, COL_DESTINATION_ID, rowId.intValue, destinationId];
    if([self execSQL:insertSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: saveEventToDestinationId: Successfully inserted event to destination mapping"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: saveEventToDestinationId: Failed to insert event to destination mapping"];
}

-(void) updateEvents {
    
}

-(NSArray<NSString*>*) getEventIdsWithDestinationMapping:(NSArray*) eventIds {
    NSString* eventIdsCSV = [RSUtils getCSVString:eventIds];
    NSString* selectSQLString = [[NSString alloc] initWithFormat:@"SELECT %@, COUNT(*) as COUNT FROM %@ WHERE %@ in (%@) GROUP BY %@;", COL_EVENT_ID, TABLE_EVENTS_TO_DESTINATION, COL_EVENT_ID, eventIdsCSV, COL_EVENT_ID];
    const char* selectSQLChar = [selectSQLString UTF8String];
    NSMutableArray<NSString*>* eventIdsWithTransformationMapping = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    @synchronized (lockObj) {
    if (sqlite3_prepare_v2(self->_database, selectSQLChar, -1, &selectStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getEventIdsWithTransformationMapping: Successfully fetched events with transformation mapping from DB"];
        while (sqlite3_step(selectStmt) == SQLITE_ROW) {
            int eventId = sqlite3_column_int(selectStmt, 0);
            [eventIdsWithTransformationMapping addObject:@(eventId).stringValue];
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: getEventIdsWithTransformationMapping: Failed to fetch events with transformation mapping from DB"];
    }
    }
    return [eventIdsWithTransformationMapping copy];
}

- (void) deleteEvents:(NSArray*) eventIds withDestinationId:(NSString*) destinationId {
    NSString* eventIdsCSV = [RSUtils getCSVString:eventIds];
    NSString* deleteSQLString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = \"%@\" and %@ IN (%@);", TABLE_EVENTS_TO_DESTINATION, COL_DESTINATION_ID, destinationId, COL_EVENT_ID, eventIdsCSV];
    @synchronized (lockObj) {
    if([self execSQL:deleteSQLString]) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventsWithDestinationId: Successfully deleted events (%@) with destination Id %@", eventIdsCSV, destinationId]];
        return;
    }
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventsWithDestinationId: Failed to delete events (%@) with destination Id %@", eventIdsCSV, destinationId]];
    }
}

// given list of event Id's this would return back list of destinationId's which require transformation for that event.
-(NSDictionary<NSString*, NSArray<NSString*>*>*) getDestinationMappingofEvents:(NSArray<NSString*>*) eventIds {
    NSString* querySQLString = nil;
    if(eventIds.count>0) {
        NSString* eventIdsCSV = [RSUtils getCSVString:eventIds];
        if(eventIdsCSV != nil && eventIdsCSV.length !=0){
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%@) ORDER BY %@ ASC", TABLE_EVENTS_TO_DESTINATION, COL_EVENT_ID, eventIdsCSV, COL_EVENT_ID];
        }
    }
    if(querySQLString == nil) {
        querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC", TABLE_EVENTS_TO_DESTINATION, COL_EVENT_ID];
    }
    NSMutableDictionary<NSString*, NSMutableArray<NSString*>*>* eventsToDestinationsMapping = [[NSMutableDictionary alloc] init];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getDestinationMappingofEvents: %@", querySQLString]];
    const char* querySQL = [querySQLString UTF8String];
    sqlite3_stmt *queryStmt = nil;
    if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getDestinationMappingofEvents: Successfully fetched destinations to events mapping from DB"];
        while (sqlite3_step(queryStmt) == SQLITE_ROW) {
            NSString* eventId =  [[NSString alloc] initWithFormat:@"%d", sqlite3_column_int(queryStmt, 0)];
            const unsigned char* queryResultCol1 = sqlite3_column_text(queryStmt, 1);
            NSString *destinationId = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
            if(eventsToDestinationsMapping[eventId] == nil) {
                NSMutableArray<NSString*>* destinationIdsArray = [[NSMutableArray alloc] init];
                eventsToDestinationsMapping[eventId] = destinationIdsArray;
            }
            NSMutableArray<NSString*>* destinationIdsArray = eventsToDestinationsMapping[eventId];
            [destinationIdsArray addObject:destinationId];
            eventsToDestinationsMapping[eventId] = destinationIdsArray;
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: getDestinationMappingofEvents: Failed to fetch events to destination mapping from DB"];
    }
    return [eventsToDestinationsMapping copy];
}

-(BOOL) execSQL: (NSString*) sqlCommand {
    BOOL executionStatus = NO;
    const char* sqlCommandUTF = [sqlCommand UTF8String];
    sqlite3_stmt *SqlStatement = nil;
    if (sqlite3_prepare_v2(self->_database, sqlCommandUTF, -1, &SqlStatement, nil) == SQLITE_OK) {
        if (sqlite3_step(SqlStatement) == SQLITE_DONE) {
            executionStatus = YES;
        }
        else {
            [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: execSQL: SQLite Command Execution Failed: %@", sqlCommand]];
        }
    } else {
        [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: execSQL: SQLite Command Preparation Failed: %@", sqlCommand]];
    }
    sqlite3_finalize(SqlStatement);
    return executionStatus;
}
@end
