//
//  StorageMigratorV1V2.swift
//  Rudder
//
//  Created by Pallab Maiti on 02/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

protocol StorageMigrator {
    var currentStorage: Storage { get set }
    func migrate() throws
}

class StorageMigratorV1V2: StorageMigrator {
    let oldSQLiteStorage: SQLiteStorage
    var currentStorage: Storage
    
    init(oldSQLiteStorage: SQLiteStorage, currentStorage: Storage) {
        self.oldSQLiteStorage = oldSQLiteStorage
        self.currentStorage = currentStorage
    }
    
    func migrate() throws {
        let databasePath = oldSQLiteStorage.database.path.appendingPathComponent(oldSQLiteStorage.database.name).path
        guard FileManager.default.fileExists(atPath: databasePath) else {
            throw StorageError.databaseNotExists
        }
        let result = oldSQLiteStorage.objects(limit: .max)
        switch result {
        case .success(let list):
            list.forEach({ _ = currentStorage.save($0) })
            _ = oldSQLiteStorage.close()
            try FileManager.default.removeItem(atPath: databasePath)
        case .failure(let error):
            throw error
        }
    }
}
