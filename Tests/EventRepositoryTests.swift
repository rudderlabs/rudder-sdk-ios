//
//  EventRepositoryTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class EventRepositoryTests: XCTestCase {

    var eventRepository: RSEventRepository!
    
    override func setUp() {
        super.setUp()
        eventRepository = RSEventRepository()
    }

    override func tearDown() {
        super.tearDown()
        eventRepository = nil
    }

    func test_applyIntegrations_EmptyMessageOption_EmptyDefaultOption() {
        let expectedIntegrations = ["All": true as NSObject]
        
        let options = RSOption()
        
        let defaultOption = RSOption()
        
        let message = RSMessageBuilder()
            .setRSOption(options)
            .build()
        
        eventRepository.applyIntegrations(message, withDefaultOption: defaultOption)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.integrations)
        XCTAssertEqual(message.integrations, expectedIntegrations)
    }
    
    func test_applyIntegrations_MessageOption_EmptyDefaultOption() {
        let expectedIntegrations = ["test_integration": true as NSObject, "All": true as NSObject]
        
        let options = RSOption()
        options.putIntegration("test_integration", isEnabled: true)
        
        let defaultOption = RSOption()
        
        let message = RSMessageBuilder()
            .setRSOption(options)
            .build()
        
        eventRepository.applyIntegrations(message, withDefaultOption: defaultOption)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.integrations)
        XCTAssertEqual(message.integrations, expectedIntegrations)
    }
    
    func testApplySession() {
        
        let internalRudderConfig = RSConfigBuilder()
            .build()
        RSElementCache.initiate(with: internalRudderConfig)
        
        let userSession = RSUserSession.initiate(internalRudderConfig.sessionInActivityTimeOut, with: RSPreferenceManager.getInstance())
        userSession.start()
        
        let message = RSMessageBuilder()
            .build()

        eventRepository.applySession(message, with: userSession, andRudderConfig: internalRudderConfig)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.context)
        XCTAssertNotNil(message.context.sessionId)
        XCTAssertTrue(message.context.sessionStart)
        
        let message2 = RSMessageBuilder()
            .build()
        
        eventRepository.applySession(message2, with: userSession, andRudderConfig: internalRudderConfig)
        XCTAssertNotNil(message2)
        XCTAssertNotNil(message2.context)
        XCTAssertNotNil(message2.context.sessionId)
        XCTAssertTrue(!message2.context.sessionStart)
        
        XCTAssertEqual(message.context.sessionId, message2.context.sessionId)
    }
}
