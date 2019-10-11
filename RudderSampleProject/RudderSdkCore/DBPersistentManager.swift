//
//  DBPersistentManager.swift
//  RudderPlugin_iOS
//
//  Created by Arnab Pal on 14/09/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation
import SQLite3

class DBPersistentManager {
    private static var instance: DBPersistentManager? = nil
    private var dbInstance: OpaquePointer? = nil
    
    static func getInstance() -> DBPersistentManager {
        if (instance == nil) {
            instance = DBPersistentManager()
        }
        return instance!
    }
    
    private init() {
        createDB()
        createSchema()
    }
    
    private func createDB() {
        if (dbInstance == nil) {
            sqlite3_shutdown()
            
            if (sqlite3_open_v2(Utils.getPath(fileName: "rl_persistance.db"), &self.dbInstance, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK) {
                RudderLogger.logDebug(message: "DB created")
            } else {
                RudderLogger.logError(message: "DB could not be created")
            }
        }
    }
 
    /*
     * create table initially if not exists
     * */
    private func createSchema() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT NOT NULL,
            updated INTEGER NOT NULL);
        """
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbInstance, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                 RudderLogger.logDebug(message: "Schema created")
            } else {
                RudderLogger.logError(message: "Schema could not be created")
            }
        } else {
            RudderLogger.logError(message: "CREATE TABLE statement could not be prepared")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    /*
     * save individual messages to DB
     * */
    func saveEvent(messageJson: String) {
        let insertStatementString = "INSERT INTO events (message, updated) VALUES ('"+messageJson+"', "+String(Utils.gettimeStampLong())+");"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbInstance, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                RudderLogger.logDebug(message: "Successfully inserted event")
            } else {
                RudderLogger.logError(message: "Could not insert row")
            }
        } else {
            RudderLogger.logError(message: "INSERT statement could not be prepared")
        }
        sqlite3_finalize(insertStatement)
    }
    
    /*
     * remove selected events from persistence database storage
     * */
    func clearEventsFromDB(messageIds: [Int32]) {
        var messageIdCsv = ""
        for index in 0..<messageIds.count {
            messageIdCsv.append(String(messageIds[index]))
            if (index != messageIds.count-1) {
                messageIdCsv.append(contentsOf: ",")
            }
        }
        let deleteStatementStirng = "DELETE FROM events WHERE id IN ("+messageIdCsv+");"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbInstance, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                RudderLogger.logDebug(message: "Successfully deleted messages")
            } else {
                RudderLogger.logError(message: "Could not delete messages")
            }
        } else {
            RudderLogger.logError(message: "DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    
    func fetchEventsFromDB(count: Int32) -> RudderDBMessage {
        let queryStatementString = "SELECT * FROM events ORDER BY updated ASC LIMIT "+String(count)
        var messageIds: [Int32] = []
        var messages: [String] = []
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbInstance, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let messageId = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let message = String(cString: queryResultCol1!)
                messageIds.append(messageId)
                messages.append(message)
            }
        } else {
            RudderLogger.logError(message: "SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return RudderDBMessage(messageIds: messageIds, messages: messages)
    }
    
    func getDBRecordCount() -> Int32 {
        var count: Int32 = 0
        let countQuereStatementString = "SELECT COUNT(*) FROM 'events';"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbInstance, countQuereStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                count = sqlite3_column_int(queryStatement, 0)
            }
        } else {
            RudderLogger.logError(message: "SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return count
    }
}
