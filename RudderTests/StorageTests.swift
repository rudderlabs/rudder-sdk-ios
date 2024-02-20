//
//  StorageTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/05/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class StorageTests: XCTestCase {

    var storageWorker: StorageWorkerType!
    
    override func setUp() {
        super.setUp()
        let storage = TestStorage()
        storageWorker = TestStorageWorker(storage: storage)
        storageWorker.open()
    }
    
    func test_saveMessage() {
        let entityList = getMessageEntity(by: 1)
        
        entityList.forEach({ storageWorker.saveMessage($0) })

        XCTAssertEqual(TestStorage.messageList.first?.message, getMessage(index: 1))
        storageWorker.clearAll()
    }
    
    func test_fetchMessages() {
        let entityList = getMessageEntity(by: 3)
        
        entityList.forEach({ storageWorker.saveMessage($0) })
        
        var messageList = storageWorker.fetchMessages(by: 5)
        
        XCTAssertEqual(messageList?.count, entityList.count)
        
        messageList = storageWorker.fetchMessages(by: 2)
        
        XCTAssertEqual(messageList?.count, 2)
        storageWorker.clearAll()
    }
    
    func test_clearMessages() {
        let entityList = getMessageEntity(by: 3)
        
        entityList.forEach({ storageWorker.saveMessage($0) })

        let ids = TestStorage.messageList.compactMap({ $0.id })
        
        storageWorker.clearMessages(for: ids)
        
        XCTAssertEqual(TestStorage.messageList?.count, 0)
        storageWorker.clearAll()
    }
    
    func test_getMessageCount() {
        let entityList = getMessageEntity(by: 3)
        
        entityList.forEach({ storageWorker.saveMessage($0) })

        XCTAssertEqual(TestStorage.messageList?.count, storageWorker.getMessageCount())
        storageWorker.clearAll()
    }
    
    func test_clearAll() {
        let entityList = getMessageEntity(by: 3)
        
        entityList.forEach({ storageWorker.saveMessage($0) })

        storageWorker.clearAll()
        XCTAssertEqual(TestStorage.messageList?.count, 0)
    }
    
    func test_All() {
        let entityList = getMessageEntity(by: 5)
        
        entityList.forEach({ storageWorker.saveMessage($0) })

        XCTAssertEqual(TestStorage.messageList?.count, 5)
        
        var messageList = storageWorker.fetchMessages(by: 2)
        
        XCTAssertEqual(messageList!.count, 2)
        
        let count = storageWorker.getMessageCount()
        
        XCTAssertEqual(storageWorker.getMessageCount(), 5)
        
        let entity = entityList[3]
        
        storageWorker.clearMessages(for: [entity.id])
        
        XCTAssertEqual(TestStorage.messageList[0].message, getMessage(index: 1))
        XCTAssertEqual(TestStorage.messageList[1].message, getMessage(index: 2))
        XCTAssertEqual(TestStorage.messageList[2].message, getMessage(index: 3))
        XCTAssertEqual(TestStorage.messageList[3].message, getMessage(index: 5))
        
        XCTAssertEqual(storageWorker.getMessageCount(), 4)
        
        storageWorker.clearAll()
        XCTAssertEqual(storageWorker.getMessageCount(), 0)

    }
    
    func getMessage(index: Int) -> String {
        return 
            """
            {
                "key_\(index)": "value_\(index)"
            }
            """
    }
    
    func getMessageEntity(by count: Int) -> [RSMessageEntity] {
        var entityList = [RSMessageEntity]()
        for i in 1...count {
            let message = getMessage(index: i)
            entityList.append(RSMessageEntity(id: UUID().uuidString, message: message))
        }
        return entityList
    }
    
    override func tearDown() {
        super.tearDown()
        storageWorker = nil
    }
}

class TestStorage: Storage {
    static var messageList: [RSMessageEntity]!
        
    func open() -> Rudder.Results<Bool> {
        Self.messageList = [RSMessageEntity]()
        return .success(true)
    }
    
    func save(_ object: Rudder.RSMessageEntity) -> Rudder.Results<Bool> {
        Self.messageList.append(object)
        return .success(true)
    }
    
    func objects(by count: Int) -> Rudder.Results<[Rudder.RSMessageEntity]> {
        if count <= Self.messageList.count {
            return .success(Array(Self.messageList[0..<count]))
        }
        return .success(Self.messageList)
    }
    
    func delete(_ objects: [Rudder.RSMessageEntity]) -> Rudder.Results<Bool> {
        objects.forEach { message in
            Self.messageList.removeAll(where: { $0.id == message.id })
        }
        return .success(true)
    }
    
    func deleteAll() -> Rudder.Results<Bool> {
        Self.messageList.removeAll()
        return .success(true)
    }
    
    func count() -> Rudder.Results<Int> {
        return .success(Self.messageList.count)
    }
}

class TestStorageWorker: StorageWorker {
    
    override func open() {
        storage.open()
    }
    
    override func saveMessage(_ message: RSMessageEntity) {
        storage.save(message)
    }
    
    override func clearMessages(for ids: [String]) {
        storage.delete(ids.compactMap({ RSMessageEntity(id: $0, message: "") }))
    }
    
    override func fetchMessages(by count: Int) -> [Rudder.RSMessageEntity]? {
        try? storage.objects(by: count).get()
    }
    
    override func getMessageCount() -> Int? {
        try? storage.count().get()
    }
    
    override func clearAll() {
        storage.deleteAll()
    }
}
