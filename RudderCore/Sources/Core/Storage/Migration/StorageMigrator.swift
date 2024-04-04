//
//  StorageMigratorV1V2.swift
//  Rudder
//
//  Created by Pallab Maiti on 02/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

protocol StorageMigrator {
    var currentStorage: Storage { get set }
    func migrate()
}

class StorageMigratorV1V2: StorageMigrator {
    
    let legacyDatabaseName = "rl_persistence.sqlite"
    lazy var legacyDatabasePath : String = { Device.current.directoryPath.appendingPathComponent(legacyDatabaseName).path
    }()
    
    let logger: Logger
    var currentStorage: Storage
    let currentSourceConfig: SourceConfig
    
    
    init(currentStorage: Storage, currentSourceConfig: SourceConfig, logger: Logger) {
        self.currentStorage = currentStorage
        self.currentSourceConfig = currentSourceConfig
        self.logger = logger
    }
    
    func migrate() {
        if isMigrationNeeded() {
            let legacyDatabase = SQLiteDatabase(path: Device.current.directoryPath, name:legacyDatabaseName)
            let legacyStorage = SQLiteStorage(database: legacyDatabase, logger: logger)
            legacyStorage.open()
            let result = legacyStorage.objects(limit: .max)
            switch result {
            case .success(let list):
                list.forEach({ _ = currentStorage.save($0) })
                _ = legacyStorage.close()
                deleteLegacyDatabase()
                logger.logDebug(.storageMigrationSuccess)
            case .failure(let error):
                logger.logError(.storageMigrationFailed(.storageError(error.localizedDescription)))
            }
        }
    }
    
    func isMigrationNeeded() -> Bool {
        guard doesLegacyDatabaseExists() else {
            logger.logDebug(.legacyDatabaseDoesNotExists)
            return false
        }
        guard let legacySourceConfig = getLegacySourceConfig()  else {
            logger.logError(.storageMigrationFailedToReadSourceConfig)
            deleteLegacyDatabase()
            return false
        }
        if legacySourceConfig.source?.id == currentSourceConfig.source?.id {
            return true
        }
        return false
    }
    
    func doesLegacyDatabaseExists() -> Bool {
        FileManager.default.fileExists(atPath: legacyDatabasePath)
    }
    
    /// We are reading legacy SourceConfig from Standard Defaults as v1 iOS SDK uses StandardDefaults
    /// SourceConfig saved by v1 iOS SDK to StandardDefaults needs to be decoded using JSONDecoder opposed to PropertyListDecoder by v2 SDK.
    func getLegacySourceConfig() -> SourceConfig? {
        let standardDefaultsWorker = UserDefaultsWorker(userDefaults: UserDefaults.standard, queue: DispatchQueue(label: "standardDefaults".queueLabel()))
        let sourceConfigString: String? = standardDefaultsWorker.read(.legacySourceConfig)
        if let sourceConfigString = sourceConfigString {
            return try? JSONDecoder().decode(SourceConfig.self, from: Data(sourceConfigString.utf8))
        }
        return nil
    }
    
    func deleteLegacyDatabase() {
        do {
            try FileManager.default.removeItem(atPath: legacyDatabasePath)
        } catch {
            logger.logError(.failedToDeleteLegacyDatabase(error.localizedDescription))
        }
    }
}
