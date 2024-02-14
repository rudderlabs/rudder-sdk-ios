//
//  SQLiteStorageTests.swift
//  RudderTests-iOS
//
//  Created by Pallab Maiti on 04/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder


final class SQLiteStorageTests: XCTestCase {
    
    var sqliteStorage: SQLiteStorage!
    
    override func setUp() {
        super.setUp()
        sqliteStorage = .mockWith(name: "sqlite_storage_test")
        sqliteStorage.open()
        sqliteStorage.deleteAll()
    }
    
    func test_saveMessage() throws {
        let entityList = getMessageEntity(by: 1)
        // Given
        entityList.forEach({ sqliteStorage.save($0) })
        
        // When
        let message = try sqliteStorage.objects(limit: 1).get().first?.message
        
        // Then
        XCTAssertEqual(message, getMessage(index: 1))
        sqliteStorage.deleteAll()
    }
    
    func test_fetchMessages() throws {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ sqliteStorage.save($0) })
        
        // When
        let messageList1 = try sqliteStorage.objects(limit: 5).get()
        let messageList2 = try sqliteStorage.objects(limit: 2).get()
        
        // Then
        XCTAssertEqual(messageList1.count, 3)
        XCTAssertEqual(messageList2.count, 2)
        sqliteStorage.deleteAll()
    }
    
    func test_clearMessages() throws {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ sqliteStorage.save($0) })
        
        let list = try sqliteStorage.objects(limit: 3).get()
        
        // When
        sqliteStorage.delete(list)
        
        // Then
        XCTAssertEqual(try sqliteStorage.count().get(), 0)
        sqliteStorage.deleteAll()
    }
    
    func test_getMessageCount() throws {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ sqliteStorage.save($0) })
        
        // When
        let count = try sqliteStorage.count().get()
        
        // Then
        XCTAssertEqual(count, 3)
        sqliteStorage.deleteAll()
    }
    
    func test_clearAll() {
        let entityList = getMessageEntity(by: 3)
        
        // Given
        entityList.forEach({ sqliteStorage.save($0) })
        
        // When
        sqliteStorage.deleteAll()
        
        // Then
        XCTAssertEqual(try sqliteStorage.count().get(), 0)
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
        sqliteStorage = nil
    }
}
