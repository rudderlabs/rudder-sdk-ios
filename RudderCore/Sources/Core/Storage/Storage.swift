//
//  Storage.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public typealias Results<T> = Result<T, StorageError>

public enum StorageError: Error, Equatable {
    case storageError(String)
    case databaseNotExists
    
    var description: String {
        switch self {
        case .storageError(let string):
            return string
        case .databaseNotExists:
            return "Old database not exists, hence no migration needed"
        }
    }
}

public protocol Storage {
    @discardableResult func open() -> Results<Bool>
    @discardableResult func save(_ object: StorageMessage) -> Results<Bool>
    func objects(limit: Int) -> Results<[StorageMessage]>
    @discardableResult func delete(_ objects: [StorageMessage]) -> Results<Bool>
    @discardableResult func deleteAll() -> Results<Bool>
    func count() -> Results<Int>
    @discardableResult func close() -> Results<Bool>
}
