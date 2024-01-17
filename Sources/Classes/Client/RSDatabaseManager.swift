//
//  RSDatabaseManager.swift
//  RudderStack
//
//  Created by Pallab Maiti on 10/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import SQLite3

class RSDatabaseManager {
    
    private let database: OpaquePointer?
    private let syncQueue = DispatchQueue(label: "database.rudder.com")
    private let lock = NSLock()
    
    init() {
        database = Self.openDatabase()
        createTable()
    }
    
    static func getDBPath() -> String {
        let urlDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        let fileUrl = urlDirectory.appendingPathComponent("rl_persistence.sqlite")
        return fileUrl.path
    }
    
    static func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        if sqlite3_open_v2(getDBPath(), &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            return db
        } else {
            return nil
        }
    }
        
    func createTable() {
        var createTableStatement: OpaquePointer?
        let createTableString = "CREATE TABLE IF NOT EXISTS events( id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT NOT NULL, updated INTEGER NOT NULL);"
        Logger.log(message: "createTableSQL: \(createTableString)", logLevel: .debug)
        if sqlite3_prepare_v2(database, createTableString, -1, &createTableStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                Logger.log(message: ("DB Schema created"), logLevel: .debug)
            } else {
                Logger.log(message: "DB Schema creation error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Logger.log(message: "DB Schema CREATE statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
        }
        sqlite3_finalize(createTableStatement)
    }
    
    private func saveEvent(_ message: String) {
        let insertStatementString = "INSERT INTO events (message, updated) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, ((message.replacingOccurrences(of: "'", with: "''")) as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, Int32(RSUtils.getTimeStamp()))
            Logger.log(message: "saveEventSQL: \(insertStatementString)", logLevel: .debug)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                Logger.log(message: "Event inserted to table", logLevel: .debug)
            } else {
                Logger.log(message: "Event insertion error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Logger.log(message: "Event INSERT statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
        }
        sqlite3_finalize(insertStatement)
    }
    
    private func clearEvents(_ messageIds: [String]) {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM events WHERE id IN (\((messageIds as NSArray).componentsJoined(by: ",") as NSString));"
        Logger.log(message: "deleteEventSQL: \(deleteStatementString)", logLevel: .debug)
        if sqlite3_prepare_v2(database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                Logger.log(message: "Events deleted from DB", logLevel: .debug)
            } else {
                Logger.log(message: "Event deletion error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Logger.log(message: "Event DELETE statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
        }
        sqlite3_finalize(deleteStatement)
    }
    
    private func fetchEvents(_ count: Int) -> RSDBMessage? {
        var queryStatement: OpaquePointer?
        var message: RSDBMessage?
        let queryStatementString = "SELECT * FROM events ORDER BY updated ASC LIMIT \(count);"
        Logger.log(message: "countSQL: \(queryStatementString)", logLevel: .debug)
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            var messages = [String]()
            var messageIds = [String]()
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let messageId = "\(Int(sqlite3_column_int(queryStatement, 0)))"
                guard let message = sqlite3_column_text(queryStatement, 1) else {
                    continue
                }
                messageIds.append(messageId)
                messages.append(String(cString: message))
            }
            message = RSDBMessage(messages: messages, messageIds: messageIds)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Logger.log(message: "Event SELECT statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
        }
        sqlite3_finalize(queryStatement)
        return message
    }
    
    private func fetchDBRecordCount() -> Int {
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT COUNT(*) FROM 'events'"
        Logger.log(message: "countSQL: \(queryStatementString)", logLevel: .debug)
        var count = 0
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            Logger.log(message: "count fetched from DB", logLevel: .debug)
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(queryStatement, 0))
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Logger.log(message: "count SELECT statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
        }
        sqlite3_finalize(queryStatement)
        return count
    }
    
    private func clearAllEvents() {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM 'events';"
        if sqlite3_prepare_v2(database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            Logger.log(message: "deleteEventSQL: \(deleteStatementString)", logLevel: .debug)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                Logger.log(message: "Events deleted from DB", logLevel: .debug)
            } else {
                Logger.log(message: "Event deletion error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(database))
            Logger.log(message: "Event DELETE statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
        }
        sqlite3_finalize(deleteStatement)
    }
}

extension RSDatabaseManager {
    func write(_ message: RSMessage) {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            do {
                if let jsonObject = RSUtils.handleUrlAndDateTypes(message.dictionaryValue), JSONSerialization.isValidJSONObject(jsonObject) {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        Logger.log(message: "dump: \(jsonString)", logLevel: .debug)
                        if jsonString.getUTF8Length() > MAX_EVENT_SIZE {
                            Logger.log(message: "dump: Event size exceeds the maximum permitted event size \(MAX_EVENT_SIZE)", logLevel: .error)
                            return
                        }
                        self.saveEvent(jsonString)
                    } else {
                        Logger.log(message: "dump: Can not convert to JSON", logLevel: .error)
                    }
                } else {
                    Logger.log(message: "dump: Not a valid JSON object", logLevel: .error)
                }
            } catch {
                Logger.log(message: "dump: \(error.localizedDescription)", logLevel: .error)
            }
            self.lock.unlock()
        }
    }
    
    func removeEvents(_ messageIds: [String]) {
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            self.clearEvents(messageIds)
        }
    }
    
    func getEvents(_ count: Int) -> RSDBMessage? {
        var events: RSDBMessage?
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            events = self.fetchEvents(count)
        }
        return events
    }
    
    func getDBRecordCount() -> Int {
        var count: Int = 0
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            count = self.fetchDBRecordCount()
        }
        return count
    }
    
    func removeAllEvents() {
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            self.clearAllEvents()
        }
    }
}

extension RSUtils {    
    static func handleUrlAndDateTypes(_ message: [String: Any]?) -> [String: Any]? {
        if var workingMessage = message {
            for (key, value) in workingMessage {
                if var dictValue = value as? [String: Any] {
                    convertIntoString(&dictValue)
                    workingMessage[key] = dictValue
                }
            }
            return workingMessage
        }
        return nil
    }
    
    private static func convertIntoString(_ dictValue: inout [String: Any]) {
        for (key, value) in dictValue {
            if var nestedDictValue = value as? [String: Any] {
                convertIntoString(&nestedDictValue)
                dictValue[key] = nestedDictValue
            } else if let dateValue = value as? Date {
                let dateFormatter = ISO8601DateFormatter()
                dictValue[key] = dateFormatter.string(from: dateValue)
            } else if let urlValue = value as? URL {
                dictValue[key] = urlValue.absoluteString
            }
        }
    }
}
