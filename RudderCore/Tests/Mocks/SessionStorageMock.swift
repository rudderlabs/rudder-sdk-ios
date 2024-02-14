//
//  SessionStorageMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
@testable import Rudder

class SessionStorageMock: SessionStorageProtocol {
    var value: Any?
    
    func write<T>(_ key: SessionStorageKeys, value: T?) {
        self.value = value
    }
    
    func read<T>(_ key: SessionStorageKeys) -> T? {
        return value as? T
    }
}
