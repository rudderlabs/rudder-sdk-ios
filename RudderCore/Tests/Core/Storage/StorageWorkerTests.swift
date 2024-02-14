//
//  StorageTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/05/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class StorageWorkerTests: XCTestCase {

    var storageWorker: StorageWorkerProtocol!
    
    override func setUp() {
        super.setUp()
        storageWorker = StorageWorker(
            storage: StorageMock(),
            queue: DispatchQueue(label: "testStorageWorker".queueLabel())
        )
        storageWorker.open()
        storageWorker.clearAll()
    }
    
    func test_saveMessage() {
        let entityList = getMessageEntity(by: 1)
        // Given
        entityList.forEach({ storageWorker.saveMessage($0) })
        
        // When
        let message = storageWorker.fetchMessages(limit: 1)?.first?.message
        
        // Then
        XCTAssertEqual(message, getMessage(index: 1))
        storageWorker.clearAll()
    }
    
    func test_fetchMessages() {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ storageWorker.saveMessage($0) })
        
        // When
        let messageList1 = storageWorker.fetchMessages(limit: 5)
        let messageList2 = storageWorker.fetchMessages(limit: 2)
        
        // Then
        XCTAssertEqual(messageList1?.count, 3)
        XCTAssertEqual(messageList2?.count, 2)
        storageWorker.clearAll()
    }
    
    func test_clearMessages() {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ storageWorker.saveMessage($0) })
        
        let list = storageWorker.fetchMessages(limit: 3)
        
        // When
        storageWorker.clearMessages(list!)
        
        // Then
        XCTAssertEqual(storageWorker.getMessageCount(), 0)
        storageWorker.clearAll()
    }
    
    func test_getMessageCount() {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ storageWorker.saveMessage($0) })

        // When
        let count = storageWorker.getMessageCount()
        
        // Then
        XCTAssertEqual(count, 3)
        storageWorker.clearAll()
    }
    
    func test_clearAll() {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ storageWorker.saveMessage($0) })

        // When
        storageWorker.clearAll()
        
        // Then
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
    
    func getMessageEntity(by count: Int) -> [StorageMessage] {
        var entityList = [StorageMessage]()
        for i in 1...count {
            let message = getMessage(index: i)
            entityList.append(StorageMessage(id: UUID().uuidString, message: message, updated: 1234567890))
        }
        return entityList
    }
    
    override func tearDown() {
        super.tearDown()
        storageWorker = nil
    }
}
