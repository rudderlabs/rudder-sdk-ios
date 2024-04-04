//
//  ReadWriteLock.swift
//  Rudder
//
//  Created by Pallab Maiti on 14/09/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@propertyWrapper
public final class ReadWriteLock<T> {
    var value: T
    
    private var lock = pthread_rwlock_t()

    public init(wrappedValue value: T) {
        pthread_rwlock_init(&lock, nil)
        self.value = value
    }

    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    public var wrappedValue: T {
        get {
            pthread_rwlock_rdlock(&lock)
            defer { pthread_rwlock_unlock(&lock) }
            return value
        }
        set {
            pthread_rwlock_wrlock(&lock)
            value = newValue
            pthread_rwlock_unlock(&lock)
        }
    }
}
