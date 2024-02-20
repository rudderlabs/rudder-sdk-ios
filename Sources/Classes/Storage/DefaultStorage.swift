//
//  DefaultStorage.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class DefaultStorage: Storage {
    
    private let database: Database
    
    init(database: Database) {
        self.database = database
    }

    func open() -> Results<Bool> {
        if database.open() == DB_OK {
            return .success(true)
        } else {
            return .success(false)
        }
    }
    
    func save(_ object: RSMessageEntity) -> Results<Bool> {
        let insertStatementString = "INSERT INTO events (message, updated) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        let result: Results<Bool>
        if database.prepare(insertStatementString, -1, &insertStatement, nil) == DB_OK {
            database.bind_text(insertStatement, 1, ((object.message.replacingOccurrences(of: "'", with: "''")) as NSString).utf8String, -1, nil)
            database.bind_int(insertStatement, 2, Int32(RSUtils.getTimeStamp()))
            Logger.log(message: "saveEventSQL: \(insertStatementString)", logLevel: .debug)
            if database.step(insertStatement) == DB_DONE {
                result = .success(true)
                Logger.log(message: "Event inserted to table", logLevel: .debug)
            } else {
                result = .success(false)
                Logger.log(message: "Event insertion error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            Logger.log(message: "Event INSERT statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
            result = .failure(.saveError(errorMessage))
        }
        database.finalize(insertStatement)
        return result
    }
    
    func objects(by count: Int) -> Results<[RSMessageEntity]> {
        var queryStatement: OpaquePointer?
        let result: Results<[RSMessageEntity]>
        let queryStatementString = "SELECT * FROM events ORDER BY updated ASC LIMIT \(count);"
        Logger.log(message: "countSQL: \(queryStatementString)", logLevel: .debug)
        if database.prepare(queryStatementString, -1, &queryStatement, nil) == DB_OK {
            var messageList = [RSMessageEntity]()
            while database.step(queryStatement) == DB_ROW {
                let messageId = "\(Int(database.column_int(queryStatement, 0)))"
                guard let message = database.column_text(queryStatement, 1) else {
                    continue
                }
                let messageEntity = RSMessageEntity(id: messageId, message: String(cString: message))
                messageList.append(messageEntity)
            }
            result = .success(messageList)
        } else {
            let errorMessage = String(cString: database.errmsg())
            Logger.log(message: "Event SELECT statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
            result = .failure(.saveError(errorMessage))
        }
        database.finalize(queryStatement)
        return result
    }
    
    func delete(_ objects: [RSMessageEntity]) -> Results<Bool> {
        var deleteStatement: OpaquePointer?
        let messageIds = objects.compactMap({ $0.id })
        let deleteStatementString = "DELETE FROM events WHERE id IN (\((messageIds as NSArray).componentsJoined(by: ",") as NSString))"
        Logger.log(message: "deleteEventSQL: \(deleteStatementString)", logLevel: .debug)
        let result: Results<Bool>
        if database.prepare(deleteStatementString, -1, &deleteStatement, nil) == DB_OK {
            if database.step(deleteStatement) == DB_DONE {
                result = .success(true)
                Logger.log(message: "Events deleted from DB", logLevel: .debug)
            } else {
                result = .success(false)
                Logger.log(message: "Event deletion error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            Logger.log(message: "Event DELETE statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
            result = .failure(.saveError(errorMessage))
        }
        database.finalize(deleteStatement)
        return result
    }
    
    func deleteAll() -> Results<Bool> {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM 'events'"
        let result: Results<Bool>
        if database.prepare(deleteStatementString, -1, &deleteStatement, nil) == DB_OK {
            Logger.log(message: "deleteEventSQL: \(deleteStatementString)", logLevel: .debug)
            if database.step(deleteStatement) == DB_DONE {
                result = .success(true)
                Logger.log(message: "Events deleted from DB", logLevel: .debug)
            } else {
                result = .success(false)
                Logger.log(message: "Event deletion error", logLevel: .error)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            Logger.log(message: "Event DELETE statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
            result = .failure(.saveError(errorMessage))
        }
        database.finalize(deleteStatement)
        return result
    }
    
    func count() -> Results<Int> {
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT COUNT(*) FROM 'events'"
        Logger.log(message: "countSQL: \(queryStatementString)", logLevel: .debug)
        let result: Results<Int>
        var count = 0
        if database.prepare(queryStatementString, -1, &queryStatement, nil) == DB_OK {
            Logger.log(message: "count fetched from DB", logLevel: .debug)
            while database.step(queryStatement) == DB_ROW {
                count = Int(database.column_int(queryStatement, 0))
            }
            result = .success(count)
        } else {
            let errorMessage = String(cString: database.errmsg())
            Logger.log(message: "count SELECT statement is not prepared, Reason: \(errorMessage)", logLevel: .error)
            result = .failure(.saveError(errorMessage))
        }
        database.finalize(queryStatement)
        return result
    }
}

