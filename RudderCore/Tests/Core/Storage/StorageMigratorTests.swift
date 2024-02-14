//
//  StorageMigratorTests.swift
//  RudderTests-iOS
//
//  Created by Pallab Maiti on 02/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class StorageMigratorTests: XCTestCase {
    
    func test_migrate() throws {
        // Given
        let path = FileManager.default.urls(for: .cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        let oldDatabase = SQLiteDatabase(path: path, name: "rl_persistence_test.sqlite")
        let oldSQLiteStorage = SQLiteStorage(
            database: oldDatabase,
            logger: Logger(logger: NOLogger())
        )
        
        oldSQLiteStorage.open()
        oldSQLiteStorage.deleteAll()
        
        let databasePath = path.appendingPathComponent("rl_persistence_test.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: databasePath))
        
        oldSQLiteStorage.save(StorageMessage(id: "", message: "message_3", updated: 1234567890))
        oldSQLiteStorage.save(StorageMessage(id: "", message: "message_4", updated: 1235454094))
        oldSQLiteStorage.save(StorageMessage(id: "", message: "message_5", updated: 1245935445))
        oldSQLiteStorage.save(StorageMessage(id: "", message: "message_6", updated: 1223465723))

        let currentDatabase = SQLiteDatabase(path: path, name: "rl_persistence_default_test.sqlite")
        let currentStorage = SQLiteStorage(
            database: currentDatabase,
            logger: Logger(logger: NOLogger())
        )
        
        currentStorage.open()
        currentStorage.deleteAll()
        
        currentStorage.save(StorageMessage(id: "", message: "message_1", updated: 1246573777))
        currentStorage.save(StorageMessage(id: "", message: "message_2", updated: 1223546723))
        
        XCTAssertEqual(try currentStorage.count().get(), 2)
        
        let storageMigrator = StorageMigratorV1V2(oldSQLiteStorage: oldSQLiteStorage, currentStorage: currentStorage)
        
        // When
        try storageMigrator.migrate()
        
        // Then
        XCTAssertEqual(try currentStorage.count().get(), 6)
        XCTAssertFalse(FileManager.default.fileExists(atPath: databasePath))
        
        oldSQLiteStorage.close()
        currentStorage.close()
    }
}
