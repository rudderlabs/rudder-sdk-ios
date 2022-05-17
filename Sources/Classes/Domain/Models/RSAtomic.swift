//
//  RSAtomic.swift
//  RudderStack
//
//  Created by Pallab Maiti on 14/09/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@propertyWrapper
public struct RSAtomic<T> {
    var value: T
    private let lock = NSLock()

    public init(wrappedValue value: T) {
        self.value = value
    }

    public var wrappedValue: T {
      get { return load() }
      set { store(newValue: newValue) }
    }

    func load() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    mutating func store(newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}
