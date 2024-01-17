//
//  DefaultStorage.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class DefaultStorage: Storage {
    
    let database: Database
    let logger: Logger
    
    init(database: Database, logger: Logger) {
        self.database = database
        self.logger = logger
    }

    func open() -> Results<Bool> {
        if database.open() == DatabaseError.OK {
            return createTable()
        } else {
            return .success(false)
        }
    }
    
    func createTable() -> Results<Bool> {
        var createTableStatement: OpaquePointer?
        let createTableString = "CREATE TABLE IF NOT EXISTS events( id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT NOT NULL, updated INTEGER NOT NULL);"
        let result: Results<Bool>
        logger.logDebug(.sqlStatement(createTableString))
        if database.prepare(createTableString, -1, &createTableStatement, nil) == DatabaseError.OK {
            if database.step(createTableStatement) == DatabaseError.DONE {
                result = .success(true)
                logger.logDebug(.schemaCreationSuccess)
            } else {
                result = .success(false)
                logger.logError(.schemaCreationFailure)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            logger.logError(.statementNotPrepared(errorMessage))
            result = .failure(.storageError(errorMessage))
        }
        database.finalize(createTableStatement)
        return result
    }
    
    func save(_ object: StorageMessage) -> Results<Bool> {
        let insertStatementString = "INSERT INTO events (message, updated) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        let result: Results<Bool>
        if database.prepare(insertStatementString, -1, &insertStatement, nil) == DatabaseError.OK {
            database.bind_text(insertStatement, 1, ((object.message.replacingOccurrences(of: "'", with: "''")) as NSString).utf8String, -1, nil)
            database.bind_int(insertStatement, 2, Int32(Utility.getTimeStamp()))
            logger.logDebug(.sqlStatement(insertStatementString))
            if database.step(insertStatement) == DatabaseError.DONE {
                result = .success(true)
                logger.logDebug(.eventInsertionSuccess)
            } else {
                result = .success(false)
                logger.logDebug(.eventInsertionFailure)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            logger.logError(.statementNotPrepared(errorMessage))
            result = .failure(.storageError(errorMessage))
        }
        database.finalize(insertStatement)
        return result
    }
    
    func objects(limit: Int) -> Results<[StorageMessage]> {
        var queryStatement: OpaquePointer?
        let result: Results<[StorageMessage]>
        let queryStatementString = "SELECT * FROM events ORDER BY updated ASC LIMIT \(limit);"
        logger.logDebug(.sqlStatement(queryStatementString))
        if database.prepare(queryStatementString, -1, &queryStatement, nil) == DatabaseError.OK {
            var messageList = [StorageMessage]()
            while database.step(queryStatement) == DatabaseError.ROW {
                let messageId = "\(Int(database.column_int(queryStatement, 0)))"
                guard let message = database.column_text(queryStatement, 1) else {
                    continue
                }
                let messageEntity = StorageMessage(id: messageId, message: String(cString: message))
                messageList.append(messageEntity)
            }
            result = .success(messageList)
        } else {
            let errorMessage = String(cString: database.errmsg())
            logger.logError(.statementNotPrepared(errorMessage))
            result = .failure(.storageError(errorMessage))
        }
        database.finalize(queryStatement)
        return result
    }
    
    func delete(_ objects: [StorageMessage]) -> Results<Bool> {
        var deleteStatement: OpaquePointer?
        let messageIds = objects.compactMap({ $0.id })
        let deleteStatementString = "DELETE FROM events WHERE id IN (\((messageIds as NSArray).componentsJoined(by: ",") as NSString))"
        logger.logDebug(.sqlStatement(deleteStatementString))
        let result: Results<Bool>
        if database.prepare(deleteStatementString, -1, &deleteStatement, nil) == DatabaseError.OK {
            if database.step(deleteStatement) == DatabaseError.DONE {
                result = .success(true)
                logger.logDebug(.eventDeletionSuccess)
            } else {
                result = .success(false)
                logger.logDebug(.eventDeletionFailure)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            logger.logError(.statementNotPrepared(errorMessage))
            result = .failure(.storageError(errorMessage))
        }
        database.finalize(deleteStatement)
        return result
    }
    
    func deleteAll() -> Results<Bool> {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM 'events'"
        let result: Results<Bool>
        if database.prepare(deleteStatementString, -1, &deleteStatement, nil) == DatabaseError.OK {
            logger.logDebug(.sqlStatement(deleteStatementString))
            if database.step(deleteStatement) == DatabaseError.DONE {
                result = .success(true)
                logger.logDebug(.eventDeletionSuccess)
            } else {
                result = .success(false)
                logger.logDebug(.eventDeletionFailure)
            }
        } else {
            let errorMessage = String(cString: database.errmsg())
            logger.logError(.statementNotPrepared(errorMessage))
            result = .failure(.storageError(errorMessage))
        }
        database.finalize(deleteStatement)
        return result
    }
    
    func count() -> Results<Int> {
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT COUNT(*) FROM 'events'"
        logger.logDebug(.sqlStatement(queryStatementString))
        let result: Results<Int>
        var count = 0
        if database.prepare(queryStatementString, -1, &queryStatement, nil) == DatabaseError.OK {
            logger.logDebug(.countFetched)
            while database.step(queryStatement) == DatabaseError.ROW {
                count = Int(database.column_int(queryStatement, 0))
            }
            result = .success(count)
        } else {
            let errorMessage = String(cString: database.errmsg())
            logger.logError(.statementNotPrepared(errorMessage))
            result = .failure(.storageError(errorMessage))
        }
        database.finalize(queryStatement)
        return result
    }
}
