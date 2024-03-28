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
    
    let legacyStorageName = "rl_persistence.sqlite"
    let currentStorageName = "rl_persistence_default_test.sqlite"
    
    func test_migration_when_sourceId_matches() {
        // Given
        /// creating legacy storage, and then opening it and deleting if there are any events already in the storage
        let legacyStorage = createStorage(storageName: legacyStorageName)
        legacyStorage.open()
        legacyStorage.deleteAll()
        /// adding some dummy events to the legacy storage to test the migration
        addDummyEventsToStorage(storage: legacyStorage, count: 5)
        XCTAssertEqual(try legacyStorage.count().get(), 5)
        legacyStorage.close()
        
        /// creating current storage, and then opening it and deleting if there are any events already in the storage
        let currentStorage = createStorage(storageName: currentStorageName)
        currentStorage.open()
        currentStorage.deleteAll()
        /// adding some dummy events to the current storage to test the migration
        addDummyEventsToStorage(storage: currentStorage, count: 2)
        XCTAssertEqual(try currentStorage.count().get(), 2)
        
        let currentSourceConfig = getSourceConfig(sourceId: "source1")
        /// Setting the legacy SourceConfig to same value as the current SourceConfig so that the migrator performs migration
        UserDefaults.standard.setValue(String(decoding: try! JSONEncoder().encode(currentSourceConfig), as: UTF8.self), forKey: UserDefaultsKeys.legacySourceConfig.rawValue)
        
        
        // When
        let storageMigrator = StorageMigratorV1V2(currentStorage: currentStorage, currentSourceConfig: currentSourceConfig, logger: Logger(logger: NOLogger()))
        storageMigrator.migrate()
        
        // Then
        XCTAssertEqual(try currentStorage.count().get(), 7)
        XCTAssertFalse(FileManager.default.fileExists(atPath: getStoragePath(name: legacyStorageName)))
        
        currentStorage.close()
        deleteStorage(name: legacyStorageName)
        deleteStorage(name: currentStorageName)
    }
    
    func test_migration_when_sourceIds_are_different() {
        // Given
        /// creating legacy storage, and then opening it and deleting if there are any events already in the storage
        let legacyStorage = createStorage(storageName: legacyStorageName)
        legacyStorage.open()
        legacyStorage.deleteAll()
        /// adding some dummy events to the legacy storage to test the migration
        addDummyEventsToStorage(storage: legacyStorage, count: 5)
        XCTAssertEqual(try legacyStorage.count().get(), 5)
        legacyStorage.close()
        
        /// creating current storage, and then opening it and deleting if there are any events already in the storage
        let currentStorage = createStorage(storageName: currentStorageName)
        currentStorage.open()
        currentStorage.deleteAll()
        /// adding some dummy events to the current storage to test the migration
        addDummyEventsToStorage(storage: currentStorage, count: 2)
        XCTAssertEqual(try currentStorage.count().get(), 2)
        
        let currentSourceConfig = getSourceConfig(sourceId: "source1")
        let legacySourceConfig = getSourceConfig(sourceId: "source2")
        /// Setting the legacy SourceConfig to a value different from current SourceConfig so that the migration will not happen
        UserDefaults.standard.setValue(String(decoding: try! JSONEncoder().encode(legacySourceConfig), as: UTF8.self), forKey: UserDefaultsKeys.legacySourceConfig.rawValue)
        
        
        // When
        let storageMigrator = StorageMigratorV1V2(currentStorage: currentStorage, currentSourceConfig: currentSourceConfig, logger: Logger(logger: NOLogger()))
        storageMigrator.migrate()
        
        // Then
        XCTAssertEqual(try currentStorage.count().get(), 2)
        XCTAssertTrue(FileManager.default.fileExists(atPath: getStoragePath(name: legacyStorageName)))
        
        currentStorage.close()
        deleteStorage(name: legacyStorageName)
        deleteStorage(name: currentStorageName)
    }
    
    func createStorage(storageName: String) -> SQLiteStorage {
        let database = SQLiteDatabase(path: Device.current.directoryPath, name: storageName)
        let storage = SQLiteStorage(
            database: database,
            logger: Logger(logger: NOLogger())
        )
        return storage
    }
    
    func addDummyEventsToStorage(storage: SQLiteStorage, count: Int) {
        for i in 1...count {
            storage.save(StorageMessage(id: "", message: "message_\(storage.database.name)_\(i)", updated: Utility.getTimeStamp()))
        }
    }
    
    func getStoragePath(name: String) -> String {
        Device.current.directoryPath.appendingPathComponent(name).path
    }
    
    func deleteStorage(name: String) {
        try? FileManager.default.removeItem(atPath: getStoragePath(name: name))
    }
    
    func getSourceConfig(sourceId: String) -> SourceConfig {
        SourceConfig(source: SourceConfig.Source(id: sourceId, name: nil, writeKey: nil, enabled: nil, sourceDefinitionId: nil, createdBy: nil, workspaceId: nil, deleted: nil, createdAt: nil, updatedAt: nil, destinations: nil, dataPlanes: nil))
    }
}
