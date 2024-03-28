//
//  StorageMock.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 22/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import Rudder

class StorageMock: Storage {
    var messageList = [StorageMessage]()
    
    @discardableResult
    func open() -> Rudder.Results<Bool> {
        messageList = [StorageMessage]()
        return .success(true)
    }
    
    @discardableResult
    func save(_ object: Rudder.StorageMessage) -> Rudder.Results<Bool> {
        messageList.append(object)
        return .success(true)
    }
    
    func objects(limit count: Int) -> Rudder.Results<[Rudder.StorageMessage]> {
        if count <= messageList.count {
            return .success(Array(messageList[0..<count]))
        }
        return .success(messageList)
    }
    
    @discardableResult
    func delete(_ objects: [Rudder.StorageMessage]) -> Rudder.Results<Bool> {
        objects.forEach { message in
            messageList.removeAll(where: { $0.id == message.id })
        }
        return .success(true)
    }
    
    @discardableResult
    func deleteAll() -> Rudder.Results<Bool> {
        messageList.removeAll()
        return .success(true)
    }
    
    @discardableResult
    func count() -> Rudder.Results<Int> {
        return .success(messageList.count)
    }
    
    @discardableResult
    func close() -> Results<Bool> {
        return .success(true)
    }
}

class StorageWorkerMock: StorageWorkerProtocol {
    let storage = StorageMock()
    
    func open() {
        storage.open()
    }
    
    func saveMessage(_ message: Rudder.StorageMessage) {
        storage.save(message)
    }
    
    func clearMessages(_ messages: [Rudder.StorageMessage]) {
        storage.delete(messages)
    }
    
    func fetchMessages(limit: Int) -> [Rudder.StorageMessage]? {
        try? storage.objects(limit: limit).get()
    }
    
    func getMessageCount() -> Int? {
        try? storage.count().get()
    }
    
    func clearAll() {
        storage.deleteAll()
    }
    
    func close() {
        storage.close()
    }
    
    
}
