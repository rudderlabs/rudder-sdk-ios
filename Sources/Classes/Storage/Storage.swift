//
//  Storage.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public typealias Results<T> = Result<T, StorageError>

public enum StorageError: Error {
    case saveError(String)
}

public protocol Storage {
    @discardableResult func open() -> Results<Bool>
    @discardableResult func save(_ object: RSMessageEntity) -> Results<Bool>
    func objects(by count: Int) -> Results<[RSMessageEntity]>
    @discardableResult func delete(_ objects: [RSMessageEntity]) -> Results<Bool>
    @discardableResult func deleteAll() -> Results<Bool>
    func count() -> Results<Int>
}
