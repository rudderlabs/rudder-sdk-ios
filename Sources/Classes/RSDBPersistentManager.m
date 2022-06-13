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
NSString* _Nonnull const TABLE_EVENTS_TO_TRANSFORMATION = @"events_to_transformation";
NSString* _Nonnull const COL_EVENT_ID = @"event_id";
NSString* _Nonnull const COL_TRANSFORMATION_ID = @"transformation_id";

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

- (void)createTables {
    [self createEventsTableWithVersion:RS_DB_Version];
    [self createEventsToTransformationMappingTable];
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

-(void) createEventsToTransformationMappingTable {
    NSString *createTableSQLString = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@( %@ INTEGER NOT NULL, %@ TEXT NOT NULL);", TABLE_EVENTS_TO_TRANSFORMATION, COL_EVENT_ID, COL_TRANSFORMATION_ID];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: createEventsToTransformationMappingTable: Schema: %@", createTableSQLString]];
    if([self execSQL:createTableSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: createEventsToTransformationMappingTable: successfully created the table"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: createEventsToTransformationMappingTable: failed to create the table"];
}

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

// need to synchronize
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

- (void) saveEvent:(NSNumber*) rowId toTransformationId:(NSString*) transformationId {
    NSString *insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@(%@, %@) VALUES (%d, '%@');", TABLE_EVENTS_TO_TRANSFORMATION, COL_EVENT_ID, COL_TRANSFORMATION_ID, rowId.intValue, transformationId];
    if([self execSQL:insertSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: saveEventToTransformationId: Successfully inserted event to transformation mapping"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: saveEventToTransformationId: Failed to insert event to transformation mapping"];
}

-(void) updateEvents {
    
}

-(NSArray<NSString*>*) getEventIdsWithTransformationMapping:(NSArray*) eventIds {
    NSString* eventIdsCSV = [RSUtils getCSVString:eventIds];
    NSString* selectSQLString = [[NSString alloc] initWithFormat:@"SELECT %@, COUNT(*) as COUNT FROM %@ WHERE %@ in (%@) GROUP BY %@;", COL_EVENT_ID, TABLE_EVENTS_TO_TRANSFORMATION, COL_EVENT_ID, eventIdsCSV, COL_EVENT_ID];
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

- (void) deleteEvents:(NSArray*) eventIds withTransformationId:(NSString*) transformationId {
    NSString* eventIdsCSV = [RSUtils getCSVString:eventIds];
    NSString* deleteSQLString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = \"%@\" and %@ IN (%@);", TABLE_EVENTS_TO_TRANSFORMATION, COL_TRANSFORMATION_ID, transformationId, COL_EVENT_ID, eventIdsCSV];
    @synchronized (lockObj) {
    if([self execSQL:deleteSQLString]) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventsWithTransformationId: Successfully deleted events (%@) with transformation Id %@", eventIdsCSV, transformationId]];
        return;
    }
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventsWithTransformationId: Failed to delete events (%@) with transformation Id %@", eventIdsCSV, transformationId]];
    }
}

-(NSDictionary<NSString*, NSArray<NSString*>*>*) getEventsToTransformationMapping:(NSArray<NSString*>*) messageIds {
    NSString* querySQLString = nil;
    if(messageIds.count>0) {
        NSString* messageIdsCSV = [RSUtils getCSVString:messageIds];
        if(messageIdsCSV != nil && messageIdsCSV.length !=0){
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%@) ORDER BY %@ ASC", TABLE_EVENTS_TO_TRANSFORMATION, COL_EVENT_ID, messageIdsCSV, COL_EVENT_ID];
        }
    }
    if(querySQLString == nil) {
        querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC", TABLE_EVENTS_TO_TRANSFORMATION, COL_EVENT_ID];
    }
    NSMutableDictionary<NSString*, NSMutableArray<NSString*>*>* eventsToTransformationMapping = [[NSMutableDictionary alloc] init];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getEventsToTransformationMapping: %@", querySQLString]];
    const char* querySQL = [querySQLString UTF8String];
    sqlite3_stmt *queryStmt = nil;
    if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getEventsToTransformationMapping: Successfully fetched events to transformation mapping from DB"];
        while (sqlite3_step(queryStmt) == SQLITE_ROW) {
            NSString* eventId =  [[NSString alloc] initWithFormat:@"%d", sqlite3_column_int(queryStmt, 0)];
            const unsigned char* queryResultCol1 = sqlite3_column_text(queryStmt, 1);
            NSString *transformationId = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
            if(eventsToTransformationMapping[eventId] == nil) {
                NSMutableArray<NSString*>* transformationIdsArray = [[NSMutableArray alloc] init];
                eventsToTransformationMapping[eventId] = transformationIdsArray;
            }
            NSMutableArray<NSString*>* transformationIdsArray = eventsToTransformationMapping[eventId];
            [transformationIdsArray addObject:transformationId];
            eventsToTransformationMapping[eventId] = transformationIdsArray;
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: getEventsToTransformationMapping: Failed to fetch events to transformation mapping from DB"];
    }
    return [eventsToTransformationMapping copy];
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
