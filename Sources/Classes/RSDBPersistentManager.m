//
//  DBPersistentManager.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSDBPersistentManager.h"
#import "RSLogger.h"
#import "RSMetricsReporter.h"
#import "sqlite3.h"

int const RS_DB_Version = 3;
int const DEFAULT_STATUS_VALUE = 0;
NSString* _Nonnull const TABLE_EVENTS = @"events";
NSString* _Nonnull const COL_ID = @"id";
NSString* _Nonnull const COL_MESSAGE = @"message";
NSString* _Nonnull const COL_UPDATED = @"updated";
NSString* _Nonnull const COL_STATUS = @"status";
NSString* _Nonnull const COL_DM_PROCESSED = @"dm_processed";
NSString* _Nonnull const ENCRYPTED_DB_NAME = @"rl_persistence_encrypted.sqlite";
NSString* _Nonnull const UNENCRYPTED_DB_NAME = @"rl_persistence.sqlite";

@implementation RSDBPersistentManager

- (instancetype)initWithDBEncryption:(RSDBEncryption * __nullable)dbEncryption {
    self = [super init];
    if (self) {
        self->lock = [[NSLock alloc] init];
        [self createDB:dbEncryption];
    }
    return self;
}

- (void)createDB:(RSDBEncryption * __nullable)dbEncryption {
    [self->lock lock];
    BOOL isEncryptedDBExists = [RSUtils isFileExists:ENCRYPTED_DB_NAME];
    BOOL isUnencryptedDBExists = [RSUtils isFileExists:UNENCRYPTED_DB_NAME];
    BOOL isEncryptionNeeded = [self isEncryptionNeeded:dbEncryption];
    
    if (!isEncryptedDBExists && !isUnencryptedDBExists) {
        // Fresh Install
        if (isEncryptionNeeded) {
            // Create encrypted database with key
            [self openEncryptedDB:dbEncryption.key];
        } else {
            // Open unencrypted database
            [self openUnencryptedDB];
        }
    } else if (isEncryptedDBExists) {
        if (isEncryptionNeeded) {
            // Open encrypted database with key
            [self openEncryptedDB:dbEncryption.key];
        } else {
            // Decyprt database; then open unencrypted database
            if (dbEncryption == nil) {
                [RSLogger logDebug:@"RSDBPersistentManager: createDB: please provide the key"];
            } else {
                [self openEncryptedDB:dbEncryption.key];
                int code = [self decryptDB:dbEncryption.key];
                if (code == SQLITE_OK) {
                    [RSUtils removeFile:ENCRYPTED_DB_NAME];
                    [self openUnencryptedDB];
                } else {
                    [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: createDB: Failed to decrypt, error code: %d", code]];
                }
            }
        }
    } else {
        if (isEncryptionNeeded) {
            // Encyprt database; then open encrypted database
            [self openUnencryptedDB];
            int code = [self encryptDB:dbEncryption.key];
            if (code == SQLITE_OK) {
                [RSUtils removeFile:UNENCRYPTED_DB_NAME];
                [self openEncryptedDB:dbEncryption.key];
            } else {
                [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: createDB: Failed to encrypt, error code: %d", code]];
            }
        } else {
            // Open unencrypted database
            [self openUnencryptedDB];
        }
    }
    [self->lock unlock];
}

- (BOOL)isEncryptionNeeded:(RSDBEncryption * __nullable)dbEncryption {
    if (dbEncryption == nil)
        return NO;
    if (dbEncryption.enable && [dbEncryption.key length] > 0)
        return YES;
    return NO;
}

- (void)openUnencryptedDB {
    int executeCode = sqlite3_open_v2([[self getUnencryptedDBPath] UTF8String], &(self->_database), SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil);
    if (executeCode == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: openUnencryptedDB: DB opened successfully"];
    } else {
        [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: openUnencryptedDB: Failed to open DB, SQLite error code: %d", executeCode]];
    }
}

- (void)openEncryptedDB:(NSString *)encryptionKey {
    int executeCode = sqlite3_open_v2([[self getEncryptedDBPath] UTF8String], &(self->_database), SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil);
    if (executeCode == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: openEncryptedDB: DB opened successfully"];
        const char* key = [encryptionKey UTF8String];
        executeCode = sqlite3_key(self->_database, key, (int)strlen(key));
        [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: openEncryptedDB: DB opened with key code: %d", executeCode]];
    } else {
        [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: openEncryptedDB: Failed to open DB, SQLite error code: %d", executeCode]];
    }
}

- (int)encryptDB:(NSString *)key {
    const char* attachDBSQL = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS rl_persistence_encrypted KEY '%@';", [self getEncryptedDBPath], key] UTF8String];
    
    // Attach empty encrypted database to unencrypted database
    int code = sqlite3_exec(self->_database, attachDBSQL, NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: encryptDB: ATTACH DATABASE execution code: %d", code]];
    
    // Export database
    code = sqlite3_exec(self->_database, "SELECT sqlcipher_export('rl_persistence_encrypted');", NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: encryptDB: SELECT sqlcipher_export execution code: %d", code]];
    
    // Detach encrypted database
    code = sqlite3_exec(self->_database, "DETACH DATABASE rl_persistence_encrypted;", NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: encryptDB: DETACH DATABASE execution code: %d", code]];
    
    sqlite3_close(self->_database);
    return code;
}

- (int)decryptDB:(NSString *)key {
    const char* pragmaKeySQL = [[NSString stringWithFormat:@"PRAGMA key = '%@';", key] UTF8String];

    // Set pragma key
    int code = sqlite3_exec(self->_database, pragmaKeySQL, NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: PRAGMA key execution code: %d", code]];
    
    const char* attachDBSQL = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS rl_persistence KEY '';", [self getUnencryptedDBPath]] UTF8String];

    // Disable encryption
    code = sqlite3_exec(self->_database, attachDBSQL, NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: ATTACH DATABASE execution code: %d", code]];
    
    // Export database
    code = sqlite3_exec(self->_database, "SELECT sqlcipher_export('rl_persistence');", NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: SELECT sqlcipher_export execution code: %d", code]];
    
    // Detach encrypted database
    code = sqlite3_exec(self->_database, "DETACH DATABASE rl_persistence;", NULL, NULL, NULL);
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: DETACH DATABASE execution code: %d", code]];
    
    sqlite3_close(self->_database);
    return code;
}

- (NSString *)getEncryptedDBPath {
    return [RSUtils getFilePath:ENCRYPTED_DB_NAME];
}

- (NSString *)getUnencryptedDBPath {
    return [RSUtils getFilePath:UNENCRYPTED_DB_NAME];
}

// checks the events table for status column and would add the column, if missing.
// Migration is needed when an application is updated to the latest version of SDK from a version which doesn't has the status column in its events table
- (void)checkForMigrations {
    [RSLogger logDebug:@"RSDBPersistentManager: checkForMigrations: checking if the event table has status column"];
    bool isNewColumnAdded = NO;
    if(![self checkIfColumnExists:COL_STATUS]) {
        [RSLogger logDebug:@"RSDBPersistentManager: checkForMigrations: events table doesn't has the status column performing migration"];
        [self performMigration:COL_STATUS];
        isNewColumnAdded = YES;
    }
    if(![self checkIfColumnExists:COL_DM_PROCESSED]) {
        [RSLogger logDebug:@"RSDBPersistentManager: checkForMigrations: events table doesn't has the dm_processed column performing migration"];
        [self performMigration:COL_DM_PROCESSED];
        isNewColumnAdded = YES;
    }
    if (!isNewColumnAdded) {
        [RSLogger logDebug:@"RSDBPersistentManager: checkForMigrations: event table has status and dm_processed columns, no migration required"];
    }
}

- (BOOL) checkIfColumnExists:(NSString *) newColumn {
    NSString* checkIfNewColumnExistsSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) from pragma_table_info(\"%@\") where name=\"%@\";", TABLE_EVENTS, newColumn];
    const char* newColumnCheckSQL = [checkIfNewColumnExistsSQLString UTF8String];
    sqlite3_stmt *newColumnCheckStmt = nil;
    BOOL newColumnExists = NO;
    if (sqlite3_prepare_v2(self->_database, newColumnCheckSQL, -1, &newColumnCheckStmt, nil) == SQLITE_OK) {
        if(sqlite3_step(newColumnCheckStmt) == SQLITE_ROW) {
            int count = sqlite3_column_int(newColumnCheckStmt, 0);
            if(count > 0) {
                newColumnExists = YES;
            }
        }
        else {
            [RSLogger logWarn:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: checkIfStatusColumnExists: SQLite Command Execution Failed: %@", checkIfNewColumnExistsSQLString]];
        }
    }
    else {
        [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: checkIfStatusColumnExists: SQLite Command Preparation Failed: %@", checkIfNewColumnExistsSQLString]];
    }
    sqlite3_finalize(newColumnCheckStmt);
    return newColumnExists;
}

- (void) performMigration:(NSString *) columnName {
    if ([columnName isEqualToString:COL_STATUS]) {
        NSString* alterTableSQLString = [[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER DEFAULT %d;", TABLE_EVENTS, COL_STATUS, DEFAULT_STATUS_VALUE];
        NSString* updateTableSQLString = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %d;", TABLE_EVENTS, COL_STATUS, DEVICE_MODE_PROCESSING_DONE];
        
        if([self execSQL:alterTableSQLString] && [self execSQL:updateTableSQLString]) {
            [RSLogger logDebug:@"RSDBPersistentManager: performMigration: events table migrated to add status column"];
            return;
        }
    } else if ([columnName isEqualToString:COL_DM_PROCESSED]) {
        NSString* alterTableSQLString = [[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER DEFAULT %d;", TABLE_EVENTS, COL_DM_PROCESSED, DM_PROCESSED_PENDING];
        NSString* updateTableSQLString = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = (%@ | %d), %@ = %d;", TABLE_EVENTS, COL_STATUS, COL_STATUS, DEVICE_MODE_PROCESSING_DONE, COL_DM_PROCESSED, DM_PROCESSED_DONE];
        
        if([self execSQL:alterTableSQLString] && [self execSQL:updateTableSQLString]) {
            [RSLogger logDebug:@"RSDBPersistentManager: performMigration: events table migrated to add dm_processed column"];
            return;
        }
    }
    [RSLogger logError:@"RSDBPersistentManager: performMigration: events table migration failed"];
}

- (void)createTables {
    [self createEventsTableWithVersion:RS_DB_Version];
}

-(void) createEventsTableWithVersion:(int) version {
    NSString *createTableSQLString;
    switch(version) {
        case 1:
            createTableSQLString = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ TEXT NOT NULL, %@ INTEGER NOT NULL);", TABLE_EVENTS, COL_ID, COL_MESSAGE, COL_UPDATED];
            break;
        case 3:
            createTableSQLString = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ TEXT NOT NULL, %@ INTEGER NOT NULL, %@ INTEGER DEFAULT %d, %@ INTEGER DEFAULT %d);", TABLE_EVENTS, COL_ID, COL_MESSAGE, COL_UPDATED, COL_STATUS, DEFAULT_STATUS_VALUE, COL_DM_PROCESSED, DM_PROCESSED_PENDING];
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

- (NSNumber*)saveEvent:(NSString *)message {
    NSString *insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@, %@) VALUES ('%@', %ld) RETURNING %@;", TABLE_EVENTS, COL_MESSAGE, COL_UPDATED, [message stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [RSUtils getTimeStampLong], COL_ID];
    
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: saveEventSQL: %@", insertSQLString]];
    
    const char* insertSQL = [insertSQLString UTF8String];
    int rowId = -1;
    sqlite3_stmt *insertStmt = nil;
    [self->lock lock];
    if (sqlite3_prepare_v2(self->_database, insertSQL, -1, &insertStmt, nil) == SQLITE_OK) {
        if (sqlite3_step(insertStmt) == SQLITE_ROW) {
            // table created
            [RSLogger logDebug:@"RSDBPersistentManager: saveEvent: Successfully inserted event to table"];
            rowId = sqlite3_column_int(insertStmt, 0);
        } else {
            [RSLogger logError:@"RSDBPersistentManager: saveEvent: Failed to insert the event"];
        }
        sqlite3_finalize(insertStmt);
    } else {
        [RSLogger logError:@"RSDBPersistentManager: saveEvent: SQLite Command Preparation Failed"];
    }
    [self->lock unlock];
    return [NSNumber numberWithInt:rowId];
}


- (void) clearOldEventsWithThreshold:(int) threshold {
    [self clearProcessedEventsFromDB];
    int recordCount = [self getDBRecordCountForMode:CLOUDMODE|DEVICEMODE];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"DBRecordCount %d", recordCount]];
    
    if (recordCount > threshold) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Old DBRecordCount %d", (recordCount - threshold)]];
        RSDBMessage *dbMessage = [self fetchEventsFromDB:(recordCount - threshold) ForMode: DEVICEMODE | CLOUDMODE];
        [self clearEventsFromDB:dbMessage.messageIds];
    }
}

- (void)clearEventsFromDB:(NSMutableArray<NSString *> *)messageIds {
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ IN (%@);", TABLE_EVENTS, COL_ID, [RSUtils getCSVString:messageIds]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventSql: %@", deleteSqlString]];
    @synchronized (self) {
        if([self execSQL:deleteSqlString]) {
            [RSLogger logDebug:@"RSDBPersistentManager: clearEventsFromDB: Successfully deleted events from DB"];
            [RSMetricsReporter report:EVENTS_DISCARDED forMetricType:COUNT withProperties:@{TYPE: OUT_OF_MEMORY} andValue:(float)messageIds.count];
            return;
        }
        [RSLogger logError:@"RSDBPersistentManager: clearEventsFromDB: Failed to delete events from DB"];
    }
}

-(RSDBMessage *)fetchEventsFromDB:(int)count ForMode:(MODES) mode {
    NSString* querySQLString = nil;
    switch(mode) {
        case CLOUDMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC LIMIT %d ;", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, DEVICE_MODE_PROCESSING_DONE, COL_UPDATED, count];
            break;
        case DEVICEMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC LIMIT %d ;", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, CLOUD_MODE_PROCESSING_DONE, COL_UPDATED, count];
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
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC ;", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, DEVICE_MODE_PROCESSING_DONE, COL_UPDATED];
            break;
        case DEVICEMODE:
            querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) ORDER BY %@ ASC ;", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, CLOUD_MODE_PROCESSING_DONE, COL_UPDATED];
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
    NSMutableArray<NSNumber *>* statusList = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber *>* dmProcessedList = [[NSMutableArray alloc] init];
    
    @synchronized (self) {
        sqlite3_stmt *queryStmt = nil;
        if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
            [RSLogger logDebug:@"RSDBPersistentManager: getEventsFromDB: Successfully fetched events from DB"];
            while (sqlite3_step(queryStmt) == SQLITE_ROW) {
                int messageId = sqlite3_column_int(queryStmt, 0);
                const unsigned char* queryResultCol1 = sqlite3_column_text(queryStmt, 1);
                NSString *message = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
                int status = sqlite3_column_int(queryStmt,3);
                int dmProcessed = sqlite3_column_int(queryStmt, 4);
                [messageIds addObject:[[NSString alloc] initWithFormat:@"%d", messageId]];
                [messages addObject:message];
                [statusList addObject:[NSNumber numberWithInt:status]];
                [dmProcessedList addObject:[NSNumber numberWithInt:dmProcessed]];
            }
        } else {
            [RSLogger logError:@"RSDBPersistentManager: getEventsFromDB: Failed to fetch events from DB"];
        }
    }
    
    RSDBMessage *dbMessage = [[RSDBMessage alloc] init];
    dbMessage.messageIds = messageIds;
    dbMessage.messages = messages;
    dbMessage.statusList = statusList;
    dbMessage.dmProcessed = dmProcessedList;
    return dbMessage;
}

// If mode is passed as DEVICEMODE, this function would return the total number of events which were waiting for the Device Mode Processing to be done
- (int) getDBRecordCountForMode:(MODES) mode {
    NSString *countSQLString = nil;
    switch(mode) {
        case DEVICEMODE:
            countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ where %@ IN (%d,%d)", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, CLOUD_MODE_PROCESSING_DONE];
            break;
        case CLOUDMODE:
            countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ where %@ IN (%d,%d)", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, DEVICE_MODE_PROCESSING_DONE];
            break;
        default:
            countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@", TABLE_EVENTS];
    }
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getDBRecordCount: countSQLString: %@", countSQLString]];
    return [self getDBRecordCoun:countSQLString];
}

-(int) getDBRecordCoun:(NSString *) countSQLString {
    int count = 0;
    const char* countSQL = [countSQLString UTF8String];
    @synchronized (self) {
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

-(void) updateEventWithId:(NSNumber *) messageId withStatus:(EVENT_PROCESSING_STATUS) status {
    [self updateEventsWithIds:@[[messageId stringValue]] withStatus:status];
}

-(void) updateEventsWithIds:(NSArray*) messageIds withStatus:(EVENT_PROCESSING_STATUS) status {
    NSString *messageIdsCsv = [RSUtils getCSVString:messageIds];
    if(messageIdsCsv != nil) {
        NSString* updateEventStatusSQL = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %@ | %d WHERE %@ IN (%@);", TABLE_EVENTS, COL_STATUS, COL_STATUS, status, COL_ID, messageIdsCsv];
        @synchronized (self) {
            if([self execSQL:updateEventStatusSQL]) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: updateEventsStatus: Successfully updated the event status for events %@", messageIdsCsv]];
                return;
            }
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: updateEventsStatus: Failed to update the status for events %@", messageIdsCsv]];
        }
    }
}

-(void) clearProcessedEventsFromDB {
    NSString* clearProcessedEventsSQL = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = %d", TABLE_EVENTS, COL_STATUS, COMPLETE_PROCESSING_DONE];
    @synchronized (self) {
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

- (BOOL) doesReturnClauseExists {
    NSString* sqliteVersion = [self getSQLiteVersion];
    if(sqliteVersion != nil) {
        NSComparisonResult result = [sqliteVersion compare:@"3.35.0" options:NSNumericSearch];
        if (result == NSOrderedDescending) {
            return YES;
        } else if (result == NSOrderedAscending) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (NSString *) getSQLiteVersion {
    NSString * sqliteVersion;
    sqlite3_stmt *sqlStatement;
    NSString *versionSqlQueryString = @"SELECT sqlite_version()";
    
    if (sqlite3_prepare_v2(self->_database, [versionSqlQueryString UTF8String], -1, &sqlStatement, NULL) == SQLITE_OK) {
        if (sqlite3_step(sqlStatement) == SQLITE_ROW) {
            const unsigned char *versionCString = sqlite3_column_text(sqlStatement, 0);
            sqliteVersion = [NSString stringWithUTF8String:(const char *)versionCString];
            [RSLogger logVerbose:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: getSQLiteVersion: Running on SQLiteVersion: %@", sqliteVersion]];
        } else {
            [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: getSQLiteVersion: SQLite Command Execution Failed: %@", versionSqlQueryString]];
        }
        sqlite3_finalize(sqlStatement);
    } else {
        [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: getSQLiteVersion: SQLite Command Preparation Failed: %@", versionSqlQueryString]];
    }
    return sqliteVersion;
}

-(RSDBMessage*)fetchDeviceModeWithProcessedPendingEventsFromDb:(int) limit {
    NSString* querySQLString = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ IN (%d,%d) AND %@ = %d ORDER BY %@ ASC LIMIT %d;", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, CLOUD_MODE_PROCESSING_DONE, COL_DM_PROCESSED, DM_PROCESSED_PENDING, COL_UPDATED, limit];
    return [self getEventsFromDB:querySQLString];
}

-(int) getDeviceModeWithProcessedPendingEventsRecordCount {
    NSString *countSQLString = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ where %@ IN (%d,%d) AND %@ = %d", TABLE_EVENTS, COL_STATUS, NOT_PROCESSED, CLOUD_MODE_PROCESSING_DONE, COL_DM_PROCESSED, DM_PROCESSED_PENDING];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getDeviceModeWithProcessedPendingEventsRecordCount: countSQLString: %@", countSQLString]];
    return [self getDBRecordCoun:countSQLString];
}

-(void) markDeviceModeTransformationAndProcessedDone:(NSNumber *) messageId {
    NSString* updateEventStatusSQL = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %@ | %d, %@ = %d WHERE %@ = %@;", TABLE_EVENTS, COL_STATUS, COL_STATUS, DEVICE_MODE_PROCESSING_DONE, COL_DM_PROCESSED, DM_PROCESSED_DONE, COL_ID, messageId];
    @synchronized (self) {
        if([self execSQL:updateEventStatusSQL]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: markDeviceModeTransformationAndProcessedDone: Successfully updated the event status and dm_processed columns for events %@", messageId]];
            return;
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: markDeviceModeTransformationAndProcessedDone: Failed to update the event status and dm_processed columns for events %@", messageId]];
    }
}

-(void) markDeviceModeProcessedDone:(NSNumber *) messageId {
    NSString* updateEventStatusSQL = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = %@;", TABLE_EVENTS, COL_DM_PROCESSED, DM_PROCESSED_DONE, COL_ID, messageId];
    @synchronized (self) {
        if([self execSQL:updateEventStatusSQL]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: markDeviceModeProcessedDone: Successfully updated the event dm_processed for events %@", messageId]];
            return;
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: markDeviceModeProcessedDone: Failed to update the dm_processed for events %@", messageId]];
    }
}
@end
