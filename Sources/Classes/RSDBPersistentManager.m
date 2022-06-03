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
NSString* _Nonnull const TABLE_EVENTS = @"events";
NSString* _Nonnull const COL_ID = @"id";
NSString* _Nonnull const COL_MESSAGE = @"message";
NSString* _Nonnull const COL_UPDATED = @"updated";
NSString* _Nonnull const COL_STATUS = @"status";
NSString* _Nonnull const TABLE_EVENTS_TO_TRANSFORMATION = @"events_to_transformation";
NSString* _Nonnull const COL_EVENT_ID = @"event_id";
NSString* _Nonnull const COL_TRANSFORMATION_ID = @"transformation_id";


NSDictionary<NSNumber*, NSNumber*>* CLOUD_MODE_STATUS_UPDATE_MAPPING;
NSDictionary<NSNumber*, NSNumber*>* DEVICE_MODE_STATUS_UPDATE_MAPPING;

@implementation RSDBPersistentManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        CLOUD_MODE_STATUS_UPDATE_MAPPING = @{@0:@2, @1:@3};
        DEVICE_MODE_STATUS_UPDATE_MAPPING = @{@0:@1, @2:@3};
        [self createDB];
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
    NSString* checkIfStatusExistsSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) from pragma_table_info(%@) where name=%@;", TABLE_EVENTS, COL_STATUS];
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
            [RSLogger logDebug:@"RSDBPersistentManager: saveEvent: Event inserted to table"];
            rowId = sqlite3_column_int(insertStmt, 0);
        } else {
            [RSLogger logError:@"RSDBPersistentManager: saveEvent: Event insertion error"];
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: saveEvent: SQLite Command Preparation Failed"];
    }
    sqlite3_finalize(insertStmt);
    return [NSNumber numberWithInt:rowId];
}

- (void)clearEventsFromDB:(NSMutableArray<NSString *> *)messageIds {
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ IN (%@);", TABLE_EVENTS, COL_ID, [self getMessageIdsCSV:messageIds]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventSql: %@", deleteSqlString]];
    if([self execSQL:deleteSqlString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: clearEventsFromDB: Events deleted from DB"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: clearEventsFromDB: Events deletion error"];
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
    
    sqlite3_stmt *queryStmt = nil;
    if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getEventsFromDB: events fetched from DB"];
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
        [RSLogger logError:@"RSDBPersistentManager: getEventsFromDB: event fetching error"];
    }
    
    RSDBMessage *dbMessage = [[RSDBMessage alloc] init];
    dbMessage.messageIds = messageIds;
    dbMessage.messages = messages;
    dbMessage.statuses = statuses;
    
    return dbMessage;
}

- (int)getDBRecordCount {
    NSString *countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@", TABLE_EVENTS];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getDBRecordCount: countSQLString: %@", countSQLString]];
    int count = 0;
    const char* countSQL = [countSQLString UTF8String];
    sqlite3_stmt *countStmt = nil;
    if (sqlite3_prepare_v2(self->_database, countSQL, -1, &countStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getDBRecordCount: count fetched from DB"];
        while (sqlite3_step(countStmt) == SQLITE_ROW) {
            count = sqlite3_column_int(countStmt, 0);
        }
    } else {
        [RSLogger logError:@"RSDBPersistentManager: getDBRecordCount: count fetching error"];
    }
    return count;
}

-(void) updateEventsWithIds:(NSArray*) messageIds withStatus:(EVENTPROCESSINGSTATUS) status {
    NSString *messageIdsCsv = [self getMessageIdsCSV:messageIds];
    if(messageIdsCsv != nil) {
        switch(status) {
            case CLOUDMODEPROCESSINGDONE:
                [self updateEventsStatus:messageIdsCsv using:CLOUD_MODE_STATUS_UPDATE_MAPPING];
                break;
            case DEVICEMODEPROCESSINGDONE:
                [self updateEventsStatus:messageIdsCsv using:DEVICE_MODE_STATUS_UPDATE_MAPPING];
                break;
            default:
                break;
        }
    }
}

-(void) updateEventsStatus:(NSString*) messageIdsCSV using:(NSDictionary<NSNumber*, NSNumber*>*) rules {
    for(NSNumber* fromStatus in rules){
        NSNumber* toStatus = rules[fromStatus];
        NSString* updateEventStatusSQL = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ IN (%@) AND %@ = %d;", TABLE_EVENTS, COL_STATUS,  toStatus.intValue, COL_ID, messageIdsCSV, COL_STATUS, fromStatus.intValue];
        if([self execSQL:updateEventStatusSQL]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: updateEventsStatus: Successfully updated the event status from %d to %d", fromStatus.intValue, toStatus.intValue]];
            return;
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: updateEventsStatus: Failed to update the event status from %d to %d", fromStatus.intValue, toStatus.intValue]];
    }
}

-(void) clearProcessedEventsFromDB {
    NSString* clearProcessedEventsSQL = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = %d", TABLE_EVENTS, COL_STATUS, COMPLETEPROCESSINGDONE];
    if([self execSQL:clearProcessedEventsSQL]){
        [RSLogger logDebug:@"RSDBPersistentManager: clearProcessedEventsFromDB: Successfully cleared the processed events from the db"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: clearProcessedEventsFromDB: Failed to clear the processed events from the db"];
}

- (void)flushEventsFromDB {
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM %@", TABLE_EVENTS];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: flushEventsFromDB: deleteEventSql: %@", deleteSqlString]];
    if([self execSQL:deleteSqlString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: flushEventsFromDB: Events deleted from DB"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: flushEventsFromDB: Event deletion error"];
}

- (void) saveEvent:(NSNumber*) rowId toTransformationId:(NSString*) transformationId {
    NSString *insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@(%@, %@) VALUES (%d, '%@');", TABLE_EVENTS_TO_TRANSFORMATION, COL_EVENT_ID, COL_TRANSFORMATION_ID, rowId.intValue, transformationId];
    if([self execSQL:insertSQLString]) {
        [RSLogger logDebug:@"RSDBPersistentManager: saveEventToTransformationId: Successfully inserted event to transformation mapping"];
        return;
    }
    [RSLogger logError:@"RSDBPersistentManager: saveEventToTransformationId: Failed to insert event to transformation mapping"];
}

-(NSDictionary<NSNumber*, NSString*>*) getEventsToTransformationMapping {
    NSMutableDictionary<NSNumber*, NSString*>* eventsToTransformationMapping = [[NSMutableDictionary alloc] init];
    NSString *querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC", TABLE_EVENTS, COL_UPDATED];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getEventsToTransformationMapping: %@", querySQLString]];
    const char* querySQL = [querySQLString UTF8String];
    sqlite3_stmt *queryStmt = nil;
    if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: getEventsToTransformationMapping: Successfully fetched events to transformation mapping from DB"];
        while (sqlite3_step(queryStmt) == SQLITE_ROW) {
            NSNumber* eventId = [NSNumber numberWithInt:sqlite3_column_int(queryStmt, 0)];
            const unsigned char* queryResultCol1 = sqlite3_column_text(queryStmt, 1);
            NSString *transformationId = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
            eventsToTransformationMapping[eventId] = transformationId;
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

-(NSString*) getMessageIdsCSV:(NSArray*) messageIds{
    NSMutableString *messageIdsCsv = [[NSMutableString alloc] init];
    for (int index = 0; index < messageIds.count; index++) {
        [messageIdsCsv appendString:messageIds[index]];
        if (index != messageIds.count -1) {
            [messageIdsCsv appendString:@","];
        }
    }
    return [messageIdsCsv copy];
}

@end
