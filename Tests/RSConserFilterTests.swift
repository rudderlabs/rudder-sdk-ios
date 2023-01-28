//
//  RSConserFilterTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class RSConserFilterTests: XCTestCase {

    var consentInterceptorList: [RSConsentInterceptor]!
    var consentFilter: RSConsentFilter!
    
    override func setUp() {
        super.setUp()
        consentInterceptorList = [RSConsentInterceptor]()
        let serverConfig = RSServerConfigSource()
        consentFilter = RSConsentFilter(consentInterceptorList, withServerConfig: serverConfig)
    }

    override func tearDown() {
        super.tearDown()
        consentInterceptorList = nil
        consentFilter = nil
    }

    func testAppliedConsentsMessage_EventName() {
        let message = RSMessageBuilder()
            .setEventName("Test Track")
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.event, "Test Track")
    }
    
    func testAppliedConsentsMessage_Type() {
        let message = RSMessageBuilder()
            .build()

        message.type = RSTrack
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.type, RSTrack)
    }
    
    func testAppliedConsentsMessage_UserId() {
        let message = RSMessageBuilder()
            .setUserId("test_user_id")
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.userId, "test_user_id")
    }
    
    func testAppliedConsentsMessage_PreviousId() {
        let message = RSMessageBuilder()
            .setPreviousId("test_previous_id")
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.previousId, "test_previous_id")
    }
    
    func testAppliedConsentsMessage_GroupId() {
        let message = RSMessageBuilder()
            .setGroupId("test_group_id")
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.groupId, "test_group_id")
    }
        
    func testAppliedConsentsMessage_Properties() {
        let expectedDict: [String: NSObject] = ["key_1": "value_1" as NSObject, "key_2": "value_2" as NSObject]
        
        let message = RSMessageBuilder()
            .setPropertyDict(expectedDict)
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertNotNil(updatedMessage.properties)
        XCTAssertEqual(updatedMessage.properties, expectedDict)
    }
    
    func testAppliedConsentsMessage_Integration() {
        let options = RSOption()
        options.putIntegration("test_integration", isEnabled: true)
        
        let message = RSMessageBuilder()
            .setRSOption(options)
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertNotNil(updatedMessage.integrations)
        XCTAssertEqual(updatedMessage.integrations, ["test_integration": true as NSObject])
    }
    
    func testAppliedConsentsMessage_CustomContexts() {
        let expectedDict: [String: NSObject] = ["key_1": "value_1" as NSObject, "key_2": "value_2" as NSObject]
        
        let options = RSOption()
        options.putCustomContext(expectedDict, withKey: "key_1")
        
        let message = RSMessageBuilder()
            .setRSOption(options)
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertNotNil(updatedMessage.customContexts)
        XCTAssertTrue(updatedMessage.customContexts is [String: [String: NSObject]])
        XCTAssertEqual(updatedMessage.customContexts as! [String: [String: NSObject]], ["key_1": ["key_1": "value_1" as NSObject, "key_2": "value_2" as NSObject]])
    }
    
    func testAppliedConsentsMessage_GroupTraits() {
        let expectedDict: [String: String] = ["key_1": "value_1", "key_2": "value_2"]
        
        let message = RSMessageBuilder()
            .setGroupTraits(expectedDict)
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        
        XCTAssertTrue(updatedMessage.traits is [String: String])
        let updatedMessageTraits: [String: String] = updatedMessage.traits as! [String: String]
        XCTAssertNotNil(updatedMessageTraits)
        
        XCTAssertNotNil(updatedMessageTraits["key_1"])
        XCTAssertEqual(updatedMessageTraits["key_1"], "value_1")
        
        XCTAssertNotNil(updatedMessageTraits["key_2"])
        XCTAssertEqual(updatedMessageTraits["key_2"], "value_2")
    }
    
    func testAppliedConsentsMessage_Traits() {
        RSElementCache.initiate()
        let expectedDict: [String: String] = ["key_1": "value_1", "key_2": "value_2"]
        let traits = RSTraits(dict: expectedDict)
        
        let message = RSMessageBuilder()
            .setTraits(traits)
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        
        XCTAssertTrue(updatedMessage.context.traits is [String: String])
        let updatedMessageTraits: [String: String] = updatedMessage.context.traits as! [String: String]
        XCTAssertNotNil(updatedMessageTraits)

        XCTAssertNotNil(updatedMessageTraits["key_1"])
        XCTAssertEqual(updatedMessageTraits["key_1"], "value_1")

        XCTAssertNotNil(updatedMessageTraits["key_2"])
        XCTAssertEqual(updatedMessageTraits["key_2"], "value_2")
    }
    
    func testAppliedConsentsMessage_ExternalIds() {
        let expectedId = "text_external_id"
        let expectedType = "123456"
        
        RSElementCache.initiate()
        let options = RSOption()
        options.putExternalId(expectedType, withId: expectedId)
        
        let messageBuilder = RSMessageBuilder()
        messageBuilder.setExternalIds(options)
        let message = messageBuilder
            .build()
        
        let updatedMessage = consentFilter.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        
        XCTAssertTrue(updatedMessage.context.externalIds is [[String: String]])
        let updatedMessageExternalIds: [[String: String]] = updatedMessage.context.externalIds as! [[String: String]]
        XCTAssertNotNil(updatedMessageExternalIds)
        XCTAssertTrue(!updatedMessageExternalIds.isEmpty)
        
        let external = updatedMessageExternalIds.first
        XCTAssertNotNil(external)
        XCTAssertNotNil(external!["id"])
        XCTAssertEqual(external!["id"], expectedId)
        
        XCTAssertNotNil(external!["type"])
        XCTAssertEqual(external!["type"], expectedType)
    }
}
