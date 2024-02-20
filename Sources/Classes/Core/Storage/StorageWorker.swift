//
//  StorageManager.swift
//  Rudder
//
//  Created by Pallab Maiti on 10/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import SQLite3

protocol StorageWorker {
    func open()
    func saveMessage(_ message: StorageMessage)
    func clearMessages(_ messages: [StorageMessage])
    func fetchMessages(limit: Int) -> [StorageMessage]?
    func getMessageCount() -> Int?
    func clearAll()
}

class DefaultStorageWorker: StorageWorker {
    let storage: Storage
    let queue: DispatchQueue
    
    init(storage: Storage, queue: DispatchQueue) {
        self.storage = storage
        self.queue = queue
    }
    
    func open() {
        storage.open()
    }
    
    func saveMessage(_ message: StorageMessage) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.storage.save(message)
        }
    }
    
    func fetchMessages(limit: Int) -> [StorageMessage]? {
        queue.sync {
            return try? storage.objects(limit: limit).get()
        }
    }
    
    func clearMessages(_ messages: [StorageMessage]) {
        queue.sync {
            _ = storage.delete(messages)
        }
    }
    
    func getMessageCount() -> Int? {
        queue.sync {
            return try? storage.count().get()
        }
    }
    
    func clearAll() {
        queue.sync {
            _ = storage.deleteAll()
        }
    }
}
