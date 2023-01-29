//
//  RSEventRepositoryTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class RSEventRepositoryTests: XCTestCase {

    var eventRepository: RSEventRepository!
    
    override func setUp() {
        super.setUp()
        eventRepository = RSEventRepository()
    }

    override func tearDown() {
        super.tearDown()
        eventRepository = nil
    }

    func testApplyIntegrations_EmptyMessageOption_EmptyDefaultOption() {
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
    
    func testApplyIntegrations_MessageOption_EmptyDefaultOption() {
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
    
    func testApplyIntegrations_EmptyMessageOption_DefaultOption() {
        let expectedIntegrations = ["test_integration": true as NSObject, "All": true as NSObject]
        
        let options = RSOption()
        
        let defaultOption = RSOption()
        defaultOption.putIntegration("test_integration", isEnabled: true)

        let message = RSMessageBuilder()
            .setRSOption(options)
            .build()
        
        eventRepository.applyIntegrations(message, withDefaultOption: defaultOption)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.integrations)
        XCTAssertEqual(message.integrations, expectedIntegrations)
    }
        
    func testApplyConsents() {
        let consentInterceptorList = [RSConsentInterceptor]()
        let serverConfig = RSServerConfigSource()
        let consentFilter = RSConsentFilter(consentInterceptorList, withServerConfig: serverConfig)
        
        let expectedIntegrations = ["test_integration": true as NSObject, "test_integration_2": false as NSObject]
        
        let options = RSOption()
        options.putIntegration("test_integration", isEnabled: true)
        options.putIntegration("test_integration_2", isEnabled: false)
        
        var message = RSMessageBuilder()
            .setRSOption(options)
            .build()
        
        message = eventRepository.applyConsents(message, with: consentFilter)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.integrations)
        XCTAssertEqual(message.integrations, expectedIntegrations)
    }
    
    func testApplySession() {
        RSElementCache.initiate()
        let rudderConfig = RSConfigBuilder()
            .build()
        
        let userSession = RSUserSession.initiate(rudderConfig.sessionInActivityTimeOut, with: RSPreferenceManager.getInstance())
        userSession.start()
        
        let message = RSMessageBuilder()
            .build()

        eventRepository.applySession(message, with: userSession, andRudderConfig: rudderConfig)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.context)
        XCTAssertNotNil(message.context.sessionId)
        XCTAssertTrue(message.context.sessionStart)
        
        let message2 = RSMessageBuilder()
            .build()
        
        eventRepository.applySession(message2, with: userSession, andRudderConfig: rudderConfig)
        XCTAssertNotNil(message2)
        XCTAssertNotNil(message2.context)
        XCTAssertNotNil(message2.context.sessionId)
        XCTAssertTrue(!message2.context.sessionStart)
        
        XCTAssertEqual(message.context.sessionId, message2.context.sessionId)
    }
}
