//
//  StorageManager.swift
//  RudderStack
//
//  Created by Pallab Maiti on 10/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import SQLite3

public protocol StorageWorkerType {
    func open()
    func saveMessage(_ message: RSMessageEntity)
    func clearMessages(for ids: [String])
    func fetchMessages(by count: Int) -> [RSMessageEntity]?
    func getMessageCount() -> Int?
    func clearAll()
}

class StorageWorker: StorageWorkerType {
    let storage: Storage
    let queue = DispatchQueue(label: "database.rudder.com")
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func open() {
        storage.open()
    }
    
    func saveMessage(_ message: RSMessageEntity) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.storage.save(message)
        }
    }
    
    func fetchMessages(by count: Int) -> [RSMessageEntity]? {
        queue.sync {
            return try? storage.objects(by: count).get()
        }
    }
    
    func clearMessages(for ids: [String]) {
        queue.sync {
            _ = storage.delete(ids.compactMap({ RSMessageEntity(id: $0, message: "") }))
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
