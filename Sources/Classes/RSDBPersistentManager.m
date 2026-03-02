//
//  DBPersistentManager.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSDBPersistentManager.h"
#import "RSLogger.h"
#import <sqlite3.h>
#import "RSDatabase.h"
#import "RSDatabaseProvider.h"
#import "RSDefaultDatabaseProvider.h"

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
NSString* _Nonnull const SQLCIPHER_TEST_DB_NAME = @"rl_sqlcipher_test_db.sqlite";

@implementation RSDBPersistentManager {
    NSLock* lock;
    id<RSDatabase> database;
    BOOL isReturnClauseSupported;
}

- (instancetype)initWithDBEncryption:(RSDBEncryption * __nullable)dbEncryption {
    self = [super init];
    if (self) {
        self->database = [[self getDatabaseProvider:dbEncryption] getDatabase];

        self->lock = [[NSLock alloc] init];
        [self->lock lock];
        [self createDB:dbEncryption];
        [self->lock unlock];

        isReturnClauseSupported = [self doesReturnClauseExists];
        if(isReturnClauseSupported) {
            [RSLogger logVerbose:@"RSDBPersistentManager: init: SQLiteVersion is >=3.35.0, hence return clause can be used"];
        } else {
            [RSLogger logVerbose:@"RSDBPersistentManager: init: SQLiteVersion is <3.35.0, hence return clause cannot be used"];
        }
    }
    return self;
}

- (id<RSDatabaseProvider>)getDatabaseProvider:(RSDBEncryption * __nullable)dbEncryption {
    if (dbEncryption == nil) {
        return [RSDefaultDatabaseProvider new];
    } else {
        return dbEncryption.databaseProvider;
    }
}

- (void)createDB:(RSDBEncryption * __nullable)dbEncryption {
    BOOL isEncryptedDBExists = [RSUtils isFileExists:ENCRYPTED_DB_NAME];
    BOOL isUnencryptedDBExists = [RSUtils isFileExists:UNENCRYPTED_DB_NAME];
    BOOL isEncryptionNeeded = [self isEncryptionNeeded:dbEncryption];

    if (isEncryptionNeeded && ![self isSQLCipherAvailable]) {
        [RSLogger logError:@"RSDBPersistentManager: createDB: Cannot encrypt the Database as SQLCipher wasn't linked correctly"];
        isEncryptionNeeded = NO;
    }

    // when both encrypted and unencrypted db doesn't exists
    if (!isEncryptedDBExists && !isUnencryptedDBExists) {
        // fresh Install
        if (isEncryptionNeeded) {
            // open encrypted database with key
            [self openEncryptedDB:dbEncryption.key];
        } else {
            // open unencrypted database
            [self openUnencryptedDB];
        }
    } else if (isEncryptedDBExists) {
    // when only encrypted db exists
        [self handleWhenEncryptedDBExists:dbEncryption isEncryptionNeeded:isEncryptionNeeded];
    } else {
        // when only unencrypted db exists
        [self handleWhenUnencryptedDBExists:dbEncryption isEncryptionNeeded:isEncryptionNeeded];
    }
}

- (BOOL)isEncryptionNeeded:(RSDBEncryption * __nullable)dbEncryption {
    if (dbEncryption == nil)
        return NO;
    if (dbEncryption.enable && [self doesEncryptionKeyExists:dbEncryption])
        return YES;
    return NO;
}

- (BOOL)doesEncryptionKeyExists:(RSDBEncryption * __nullable)dbEncryption {
    if (dbEncryption == nil || dbEncryption.key == nil || [dbEncryption.key length] == 0)
        return NO;
    return YES;
}

- (BOOL) isSQLCipherAvailable {
    BOOL isSQLCipherAvailable = NO;
    @try {
        void *stmt = nil;
        if ([database open_v2:[[self getSQLCipherTestDBPath] UTF8String] flags:SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX zVfs:NULL] == SQLITE_OK && [database prepare_v2:"PRAGMA cipher_version;" nBytes:-1 ppStmt:&stmt pzTail:NULL] == SQLITE_OK) {
            if ([database step:stmt] == SQLITE_ROW) {
                const unsigned char *ver = [database column_text:stmt i:0];
                if(ver != NULL) {
                    isSQLCipherAvailable = YES;
                }
            }
            [database finalize:stmt];
        }
        [self closeDB];
    }
    @catch (NSException *exception) {
        [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: isSQLCipherAvailable: Failed to check if SQLCipher is available, reason: %@", exception.reason]];   
    }
    [RSUtils removeFile:SQLCIPHER_TEST_DB_NAME];
    return isSQLCipherAvailable;
}

- (void)openUnencryptedDB {
    int executeCode = [database open_v2:[[self getUnencryptedDBPath] UTF8String] flags:SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX zVfs:NULL];
    if (executeCode == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: openUnencryptedDB: DB opened successfully"];
    } else {
        [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: openUnencryptedDB: Failed to open DB, SQLite error code: %d", executeCode]];
    }
}

- (int)openEncryptedDB:(NSString *)encryptionKey {
    int executeCode = [database open_v2:[[self getEncryptedDBPath] UTF8String] flags:SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX zVfs:NULL];
    if (executeCode == SQLITE_OK) {
        [RSLogger logDebug:@"RSDBPersistentManager: openEncryptedDB: DB opened successfully"];
        const char* key = [encryptionKey UTF8String];
        executeCode = [database key:key nKey:(int)strlen(key)];
        // if wrong key is provided, there is no error provided from `sqlite3_key` API.
        // so we are calling `sqlite3_exec` to get the code.
        executeCode = [database exec:(const char*) "SELECT count(*) FROM sqlite_master;" xCallback:NULL pArg:NULL pzErrMsg:NULL];
        [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: openEncryptedDB: DB opened with key code: %d", executeCode]];
    } else {
        [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: openEncryptedDB: Failed to open DB, SQLite error code: %d", executeCode]];
    }
    return executeCode;
}

- (void)handleWhenEncryptedDBExists:(RSDBEncryption * _Nullable)dbEncryption isEncryptionNeeded:(BOOL)isEncryptionNeeded {
    if (isEncryptionNeeded) {
        // open encrypted database with key
        int code = [self openEncryptedDB:dbEncryption.key];
        if (code == SQLITE_NOTADB) {
            // when key is wrong
            // delete encrypted database; then open new encrypted database
            // all previous events will be deleted
            [RSLogger logError:@"RSDBPersistentManager: createDB: Wrong key is provided. Deleting previous encrypted DB and creating a new encrypted DB"];
            [self closeDB];
            [RSUtils removeFile:ENCRYPTED_DB_NAME];
            [self openEncryptedDB:dbEncryption.key];
        }
        return;
    }
    
    // when encryption is not needed and no key is provided
    // delete encrypted database; then open unencrypted database
    // all previous events will be deleted
    if (![self doesEncryptionKeyExists:dbEncryption]) {
        [RSLogger logError:@"RSDBPersistentManager: createDB: No key is provided. Deleting encrypted DB and creating a new unencrypted DB"];
        [RSUtils removeFile:ENCRYPTED_DB_NAME];
        [self openUnencryptedDB];
        return;
    }
    
    // when encryption is not needed and a key is provided
    int code = [self openEncryptedDB:dbEncryption.key];
    switch (code) {
            // when key is correct
            // decyprt database; then open unencrypted database
        case SQLITE_OK: {
            code = [self decryptDB:dbEncryption.key];
            if (code == SQLITE_OK) {
                [self deleteEncryptedAndOpenUnEncryptedDB];
            } else {
                // when decryption of encrypted database failed
                // delete encrypted database; then open unencrypted database
                // all previous events will be deleted
                [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: createDB: Failed to decrypt the existing encrypted db, creating a new unencrypted db, error code: %d", code]];
                [self deleteEncryptedAndOpenUnEncryptedDB];
            }
        }
            break;
            
            // when key is wrong
            // delete encrypted database; then open unencrypted database
            // all previous events will be deleted
        case SQLITE_NOTADB: {
            [RSLogger logError:@"RSDBPersistentManager: createDB: Wrong key is provided. Deleting encrypted DB and creating a new unencrypted DB"];
            [self deleteEncryptedAndOpenUnEncryptedDB];
        }
            break;
            
        default:
            // when failed to open encrypted database due to any reason
            // delete encrypted database; then open unencrypted database
            // all previous events will be deleted
            [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: createDB: Failed to open the existing encrypted DB, creating a new unencrypted db, error code: %d", code]];
            [self deleteEncryptedAndOpenUnEncryptedDB];
            break;
    }
    
}

- (void)handleWhenUnencryptedDBExists:(RSDBEncryption * _Nullable)dbEncryption isEncryptionNeeded:(BOOL)isEncryptionNeeded {
    if (isEncryptionNeeded) {
        // encrypt database; then open encrypted database
        [self openUnencryptedDB];
        int code = [self encryptDB:dbEncryption.key];
        if (code == SQLITE_OK) {
            [self deleteUnEncryptedAndOpenEncryptedDB:dbEncryption];
        } else {
            // when encryption failed
            // delete unencrypted database; then create new encrypted database
            // all previous events will be deleted
            [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: createDB: Failed to encrypt the existing unecnrypted db, creating a new encrypted db, error code: %d", code]];
            [self deleteUnEncryptedAndOpenEncryptedDB:dbEncryption];
        }
    } else {
        // open unencrypted database
        [self openUnencryptedDB];
    }
}


- (void)deleteEncryptedAndOpenUnEncryptedDB {
    [self closeDB];
    [RSUtils removeFile:ENCRYPTED_DB_NAME];
    [self openUnencryptedDB];
}

- (void)deleteUnEncryptedAndOpenEncryptedDB:(RSDBEncryption * _Nullable)dbEncryption {
    [self closeDB];
    [RSUtils removeFile:UNENCRYPTED_DB_NAME];
    [self openEncryptedDB:dbEncryption.key];
}


- (int)encryptDB:(NSString *)key {
    const char* attachDBSQL = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS rl_persistence_encrypted KEY '%@';", [self getEncryptedDBPath], key] UTF8String];
    
    // Attach empty encrypted database to unencrypted database
    int code = [database exec:attachDBSQL xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: encryptDB: ATTACH DATABASE execution code: %d", code]];
    
    // Export database
    code = [database exec:"SELECT sqlcipher_export('rl_persistence_encrypted');" xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: encryptDB: SELECT sqlcipher_export execution code: %d", code]];
    
    // Detach encrypted database
    code = [database exec:"DETACH DATABASE rl_persistence_encrypted;" xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: encryptDB: DETACH DATABASE execution code: %d", code]];
    
    return code;
}

- (int)decryptDB:(NSString *)key {
    const char* pragmaKeySQL = [[NSString stringWithFormat:@"PRAGMA key = '%@';", key] UTF8String];

    // Set pragma key
    int code = [database exec:pragmaKeySQL xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: PRAGMA key execution code: %d", code]];
    
    const char* attachDBSQL = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS rl_persistence KEY '';", [self getUnencryptedDBPath]] UTF8String];

    // Disable encryption
    code = [database exec:attachDBSQL xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: ATTACH DATABASE execution code: %d", code]];
    
    // Export database
    code = [database exec:"SELECT sqlcipher_export('rl_persistence');" xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: SELECT sqlcipher_export execution code: %d", code]];
    
    // Detach encrypted database
    code = [database exec:"DETACH DATABASE rl_persistence;" xCallback:NULL pArg:NULL pzErrMsg:NULL];
    [RSLogger logDebug:[NSString stringWithFormat:@"RSDBPersistentManager: decryptDB: DETACH DATABASE execution code: %d", code]];
    
    return code;
}

- (NSString *)getSQLCipherTestDBPath {
    return [RSUtils getFilePath:SQLCIPHER_TEST_DB_NAME];
}

- (NSString *)getEncryptedDBPath {
    return [RSUtils getFilePath:ENCRYPTED_DB_NAME];
}

- (NSString *)getUnencryptedDBPath {
    return [RSUtils getFilePath:UNENCRYPTED_DB_NAME];
}

- (void)closeDB {
    [database close];
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
    void *newColumnCheckStmt = nil;
    BOOL newColumnExists = NO;
    if ([database prepare_v2:newColumnCheckSQL nBytes:-1 ppStmt:&newColumnCheckStmt pzTail:NULL] == SQLITE_OK) {
        if([database step:newColumnCheckStmt] == SQLITE_ROW) {
            int count = [database column_int:newColumnCheckStmt i:0];
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
    [database finalize:newColumnCheckStmt];
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
    NSString *insertSQLString;
    if(isReturnClauseSupported) {
        insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@, %@) VALUES ('%@', %ld) RETURNING %@;", TABLE_EVENTS, COL_MESSAGE, COL_UPDATED, [message stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [RSUtils getTimeStampLong], COL_ID];
    } else {
        insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@, %@) VALUES ('%@', %ld);", TABLE_EVENTS, COL_MESSAGE, COL_UPDATED, [message stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [RSUtils getTimeStampLong]];
    }
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: saveEventSQL: %@", insertSQLString]];
    
    const char* insertSQL = [insertSQLString UTF8String];
    int rowId = -1;
    void *insertStmt = nil;
    [self->lock lock];
    if ([database prepare_v2:insertSQL nBytes:-1 ppStmt:&insertStmt pzTail:NULL] == SQLITE_OK) {
        if(isReturnClauseSupported) {
            if ([database step:insertStmt] == SQLITE_ROW) {
                // table created
                [RSLogger logDebug:@"RSDBPersistentManager: saveEvent: Successfully inserted event to table"];
                rowId = [database column_int:insertStmt i:0];
            } else {
                [RSLogger logError:@"RSDBPersistentManager: saveEvent: Failed to insert the event"];
            }
            [database finalize:insertStmt];
        } else {
            if([database step:insertStmt] == SQLITE_DONE) {
                [database finalize:insertStmt];
                rowId = [database last_insert_rowid];
            }
        }
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
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ IN (%@);", TABLE_EVENTS, COL_ID, [RSUtils getCSVStringFromArray:messageIds]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: deleteEventSql: %@", deleteSqlString]];
    @synchronized (self) {
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
    @try {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDBPersistentManager: getEventsFromDB: fetchEventSql: %@", querySQLString]];
        
        const char* querySQL = [querySQLString UTF8String];
        NSMutableArray<NSString *> *messageIds = [NSMutableArray array];
        NSMutableArray<NSString *> *messages = [NSMutableArray array];
        NSMutableArray<NSNumber *> *statusList = [NSMutableArray array];
        NSMutableArray<NSNumber *> *dmProcessedList = [NSMutableArray array];
        
        @synchronized (self) {
            sqlite3_stmt *queryStmt = nil;
            if ([database prepare_v2:querySQL nBytes:-1 ppStmt:&queryStmt pzTail:NULL] == SQLITE_OK) {
                [RSLogger logDebug:@"RSDBPersistentManager: getEventsFromDB: Successfully fetched events from DB"];
                while ([database step:queryStmt] == SQLITE_ROW) {
                    @autoreleasepool {
                        int messageId = [database column_int:queryStmt i:0];
                        const unsigned char* queryResultCol1 = [database column_text:queryStmt i:1];
                        NSString *message = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
                        int status = [database column_int:queryStmt i:3];
                        int dmProcessed = [database column_int:queryStmt i:4];
                        
                        [messageIds addObject:[[NSString alloc] initWithFormat:@"%d", messageId]];
                        [messages addObject:message];
                        [statusList addObject:[NSNumber numberWithInt:status]];
                        [dmProcessedList addObject:[NSNumber numberWithInt:dmProcessed]];
                    }
                }
            } else {
                [RSLogger logError:@"RSDBPersistentManager: getEventsFromDB: Failed to fetch events from DB"];
            }
            
            // Finalize the SQL statement to free resources
            if (queryStmt != nil) {
                [database finalize:queryStmt];
            }
        }
        
        RSDBMessage *dbMessage = [[RSDBMessage alloc] init];
        dbMessage.messageIds = messageIds;
        dbMessage.messages = messages;
        dbMessage.statusList = statusList;
        dbMessage.dmProcessed = dmProcessedList;
        return dbMessage;
        
    } @catch (NSException *exception) {
        [RSLogger logError:[NSString stringWithFormat:@"RSDBPersistentManager: getEventsFromDB: Failed to fetch events from DB, reason: %@", exception.reason]];
        return nil;
    }
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
        void *countStmt = nil;
        if ([database prepare_v2:countSQL nBytes:-1 ppStmt:&countStmt pzTail:NULL] == SQLITE_OK) {
            [RSLogger logDebug:@"RSDBPersistentManager: getDBRecordCount: Successfully fetched events count from DB"];
            while ([database step:countStmt] == SQLITE_ROW) {
                count = [database column_int:countStmt i:0];
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
    NSString *messageIdsCsv = [RSUtils getCSVStringFromArray:messageIds];
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
    void *sqlStatement = nil;
    int code = [database prepare_v2:sqlCommandUTF nBytes:-1 ppStmt:&sqlStatement pzTail:NULL];
    if (code == SQLITE_OK) {
        if ([database step:sqlStatement] == SQLITE_DONE) {
            executionStatus = YES;
        }
        else {
            [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: execSQL: SQLite Command Execution Failed: %@", sqlCommand]];
        }
    } else {
        [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: execSQL: SQLite Command Preparation Failed: %@", sqlCommand]];
    }
    [database finalize:sqlStatement];
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
    void *sqlStatement;
    NSString *versionSqlQueryString = @"SELECT sqlite_version()";
    
    if ([database prepare_v2:[versionSqlQueryString UTF8String] nBytes:-1 ppStmt:&sqlStatement pzTail:NULL] == SQLITE_OK) {
        if ([database step:sqlStatement] == SQLITE_ROW) {
            const unsigned char *versionCString = [database column_text:sqlStatement i:0];
            sqliteVersion = [NSString stringWithUTF8String:(const char *)versionCString];
            [RSLogger logVerbose:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: getSQLiteVersion: Running on SQLiteVersion: %@", sqliteVersion]];
        } else {
            [RSLogger logError:[[NSString alloc] initWithFormat: @"RSDBPersistentManager: getSQLiteVersion: SQLite Command Execution Failed: %@", versionSqlQueryString]];
        }
        [database finalize:sqlStatement];
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
