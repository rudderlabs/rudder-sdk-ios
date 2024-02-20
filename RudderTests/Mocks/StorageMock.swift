//
//  StorageMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 22/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import Rudder

class StorageMock: Storage {
    var messageList = [StorageMessage]()
    
    func open() -> Rudder.Results<Bool> {
        messageList = [StorageMessage]()
        return .success(true)
    }
    
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
    
    func delete(_ objects: [Rudder.StorageMessage]) -> Rudder.Results<Bool> {
        objects.forEach { message in
            messageList.removeAll(where: { $0.id == message.id })
        }
        return .success(true)
    }
    
    func deleteAll() -> Rudder.Results<Bool> {
        messageList.removeAll()
        return .success(true)
    }
    
    func count() -> Rudder.Results<Int> {
        return .success(messageList.count)
    }
}
