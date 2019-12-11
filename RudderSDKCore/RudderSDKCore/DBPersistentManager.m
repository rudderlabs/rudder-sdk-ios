//
//  DBPersistentManager.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "DBPersistentManager.h"
#import "RudderLogger.h"

@implementation DBPersistentManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDB];
        [self createSchema];
    }
    return self;
}

- (void)createDB {
    if (sqlite3_open_v2([Utils getDBPath], &(self->_database), SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK) {
        // opened correctly
    }
}

- (void)createSchema {
    NSString *createTableSQLString = @"CREATE TABLE IF NOT EXISTS events( id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT NOT NULL, updated INTEGER NOT NULL);";
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"CreateTableSchema: %@", createTableSQLString]];
    const char* createTableSQL = [createTableSQLString UTF8String];
    sqlite3_stmt *createTableStmt = nil;
    if (sqlite3_prepare_v2(self->_database, createTableSQL, -1, &createTableStmt, nil) == SQLITE_OK) {
        if (sqlite3_step(createTableStmt) == SQLITE_DONE) {
            // table created
            [RudderLogger logDebug:@"DB Schema created"];
        } else {
            // table creation error
            [RudderLogger logError:@"DB Schema creation error"];
        }
    } else {
        // wrong statement
    }
    sqlite3_finalize(createTableStmt);
}

- (void)saveEvent:(NSString *)message {
    NSString *insertSQLString = [[NSString alloc] initWithFormat:@"INSERT INTO events (message, updated) VALUES ('%@', %ld);", message, [Utils getTimeStampLong]];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"saveEventSQL: %@", insertSQLString]];
    const char* insertSQL = [insertSQLString UTF8String];
    sqlite3_stmt *insertStmt = nil;
    if (sqlite3_prepare_v2(self->_database, insertSQL, -1, &insertStmt, nil) == SQLITE_OK) {
        if (sqlite3_step(insertStmt) == SQLITE_DONE) {
            // table created
            [RudderLogger logDebug:@"Event inserted to table"];
        } else {
            // table creation error
            [RudderLogger logError:@"Event insertion error"];
        }
    } else {
        // wrong statement
    }
    sqlite3_finalize(insertStmt);
}

- (void)clearEventFromDB:(int)messageId {
    
}

- (void)clearEventsFromDB:(NSArray<NSString *> *)messageIds {
    NSMutableString *messageIdsCsv = [[NSMutableString alloc] init];
    for (int index = 0; index < messageIds.count; index++) {
        [messageIdsCsv appendString:messageIds[index]];
        if (index != messageIds.count -1) {
            [messageIdsCsv appendString:@","];
        }
    }
    
    NSString *deleteSqlString = [[NSString alloc] initWithFormat:@"DELETE FROM events WHERE id IN (%@);", messageIdsCsv];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"deleteEventSql: %@", deleteSqlString]];
    const char* deleteSql = [deleteSqlString UTF8String];
    sqlite3_stmt *deleteStmt = nil;
    if (sqlite3_prepare_v2(self->_database, deleteSql, -1, &deleteStmt, nil) == SQLITE_OK) {
        if (sqlite3_step(deleteStmt) == SQLITE_DONE) {
            // delete successful
            [RudderLogger logDebug:@"Events deleted from DB"];
        } else {
            // delete failed
            [RudderLogger logError:@"Event deletion error"];
        }
    } else {
        // wrong statement
    }
    
    sqlite3_finalize(deleteStmt);
}

- (RudderDBMessage *)fetchEventsFromDB:(int)count {
    NSString *querySQLStirng = [[NSString alloc] initWithFormat:@"SELECT * FROM events ORDER BY updated ASC LIMIT %d;", count];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"fetchEventSql: %@", querySQLStirng]];
    const char* querySQL = [querySQLStirng UTF8String];
    NSMutableArray<NSString *> *messageIds = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *messages = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *queryStmt = nil;
    if (sqlite3_prepare_v2(self->_database, querySQL, -1, &queryStmt, nil) == SQLITE_OK) {
        [RudderLogger logDebug:@"events fetched from DB"];
        while (sqlite3_step(queryStmt) == SQLITE_ROW) {
            int messageId = sqlite3_column_int(queryStmt, 0);
            const unsigned char* queryResultCol1 = sqlite3_column_text(queryStmt, 1);
            NSString *message = [[NSString alloc] initWithUTF8String:(char *)queryResultCol1];
            [messageIds addObject:[[NSString alloc] initWithFormat:@"%d", messageId]];
            [messages addObject:message];
        }
    } else {
        // wrong statement
        [RudderLogger logError:@"event fetching error"];
    }
    
    RudderDBMessage *dbMessage = [[RudderDBMessage alloc] init];
    dbMessage.messageIds = messageIds;
    dbMessage.messages = messages;
    
    return dbMessage;
}

- (int)getDBRecordCount {
    NSString *countSQLString = @"SELECT COUNT(*) FROM 'events'";
    
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"countSQLStirng: %@", countSQLString]];
    
    int count = 0;
    const char* countSQL = [countSQLString UTF8String];
    
    sqlite3_stmt *countStmt = nil;
    if (sqlite3_prepare_v2(self->_database, countSQL, -1, &countStmt, nil) == SQLITE_OK) {
        [RudderLogger logDebug:@"count fetched from DB"];
        while (sqlite3_step(countStmt) == SQLITE_ROW) {
            count = sqlite3_column_int(countStmt, 0);
        }
    } else {
        // wrong statement
        [RudderLogger logError:@"count fetching error"];
    }
    
    return count;
}

- (void)deleteAllEvents {
    
}


@end
