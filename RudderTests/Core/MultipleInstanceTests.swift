//
//  MultipleInstanceTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class MultipleInstanceTests: XCTestCase {
    func test_default() {
        let instance: RSClient = .mockAny()
        
        defer {
            instance.flush()
        }
        
        XCTAssertNotNil(ClientRegistry.default)
        XCTAssertNotNil(RSClient.default)
        ClientRegistry.unregisterDefault()
    }
    
    func test_returnSameDefaultInstance() {
        let instance_1: RSClient = .mockAny()
        _ = RSClient.mockAny()
        _ = RSClient.mockAny()
        
        defer {
            instance_1.flush()
        }
        
        XCTAssertEqual(ClientRegistry.instances.count, 1)
        ClientRegistry.unregisterDefault()
    }
    
    func test_returnSameCustomInstance() {
        let instance_1: RSClient = .mockWith(instanceName: "test_1")
        _ = RSClient.mockWith(instanceName: "test_1")
        
        defer {
            instance_1.flush()
        }
        
        XCTAssertNil(RSClient.default)
        XCTAssertEqual(ClientRegistry.instances.count, 1)
        RSClient.unregisterInstance(named: "test_1")
    }
    
    func test_multiple_withDefault() {
        let instance_1: RSClient = .mockAny()
        let instance_2: RSClient = .mockWith(instanceName: "test_1")
        let instance_3: RSClient = .mockWith(instanceName: "test_2")
        
        defer {
            instance_1.flush()
            instance_2.flush()
            instance_3.flush()
        }
        
        XCTAssertNotNil(ClientRegistry.default)
        XCTAssertEqual(ClientRegistry.instances.count, 3)
        
        ClientRegistry.unregisterDefault()
        RSClient.unregisterInstance(named: "test_1")
        RSClient.unregisterInstance(named: "test_2")
    }
    
    func test_multiple_withoutDefault() {
        let instance_1: RSClient = .mockWith(instanceName: "test_1")
        let instance_2: RSClient = .mockWith(instanceName: "test_2")
        
        defer {
            instance_1.flush()
            instance_2.flush()
        }
        
        XCTAssertNil(RSClient.default)
        XCTAssertEqual(ClientRegistry.instances.count, 2)
        
        RSClient.unregisterInstance(named: "test_1")
        RSClient.unregisterInstance(named: "test_2")
    }
    
    func test_emptyInstanceName() {
        let instance: RSClient = .mockWith(instanceName: "")
        
        defer {
            instance.flush()
        }
        
        XCTAssertNotNil(RSClient.default)
        XCTAssertEqual(ClientRegistry.instances.count, 1)
        
        ClientRegistry.unregisterDefault()
    }
    
    func test_instance() {
        let instance: RSClient = .mockWith(instanceName: "test_1")
        
        defer {
            instance.flush()
        }
        
        let expectedInstance = RSClient.instance(named: "test_1")
        
        XCTAssertNotNil(expectedInstance)
        
        RSClient.unregisterInstance(named: "test_1")
    }
    
    func test_isRegistered() {
        let instance: RSClient = .mockWith(instanceName: "test_1")
        
        defer {
            instance.flush()
        }
        
        XCTAssertTrue(RSClient.isRegistered(instanceName: "test_1"))
        
        RSClient.unregisterInstance(named: "test_1")
    }
    
    func test_unregisterInstance() {
        let instance: RSClient = .mockWith(instanceName: "test_1")
        
        defer {
            instance.flush()
        }
        
        XCTAssertEqual(ClientRegistry.instances.count, 1)
        
        RSClient.unregisterInstance(named: "test_1")
        
        XCTAssertEqual(ClientRegistry.instances.count, 0)        
    }
}
