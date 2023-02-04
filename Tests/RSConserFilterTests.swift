//
//  RSConserFilterTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class RSConserFilterTests: XCTestCase {

    var consentFilter: RSConsentFilter!
    var consentFilterHandler: RSConsentFilterHandler!
    
    override func setUp() {
        super.setUp()
        consentFilter = TestConsentFilter1()
        let serverConfig = RSServerConfigSource()
        consentFilterHandler = RSConsentFilterHandler.initiate(consentFilter, withServerConfig: serverConfig)
    }

    override func tearDown() {
        super.tearDown()
        consentFilter = nil
        consentFilterHandler = nil
    }

    /*func testAppliedConsentsMessage_EventName() {
        let message = RSMessageBuilder()
            .setEventName("Test Track")
            .build()
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.event, "Test Track")
    }
    
    func testAppliedConsentsMessage_Type() {
        let message = RSMessageBuilder()
            .build()

        message.type = RSTrack
        let updatedMessage = consentFilterHandler.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.type, RSTrack)
    }
    
    func testAppliedConsentsMessage_UserId() {
        let message = RSMessageBuilder()
            .setUserId("test_user_id")
            .build()
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.userId, "test_user_id")
    }
    
    func testAppliedConsentsMessage_PreviousId() {
        let message = RSMessageBuilder()
            .setPreviousId("test_previous_id")
            .build()
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.previousId, "test_previous_id")
    }
    
    func testAppliedConsentsMessage_GroupId() {
        let message = RSMessageBuilder()
            .setGroupId("test_group_id")
            .build()
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.groupId, "test_group_id")
    }
        
    func testAppliedConsentsMessage_Properties() {
        let expectedDict: [String: NSObject] = ["key_1": "value_1" as NSObject, "key_2": "value_2" as NSObject]
        
        let message = RSMessageBuilder()
            .setPropertyDict(expectedDict)
            .build()
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
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
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
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
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
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
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
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
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
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
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
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
    
    func test_applyConsentsThreadSafety() {
        var internalConsentInterceptorList = [RSConsentInterceptor]()
        internalConsentInterceptorList.append(TestConsentInterceptor1())
        internalConsentInterceptorList.append(TestConsentInterceptor2())
        let internalServerConfig = RSServerConfigSource()
        let internalConsentFilter = RSConsentFilter.initiate(internalConsentInterceptorList, withServerConfig: internalServerConfig)

        var updatedMessageList = [RSMessage]()
        
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for i in 0..<100 {
            let message = RSMessageBuilder()
                .setEventName("Test - \(i)")
                .build()
            dispatchGroup.enter()
            DispatchQueue.global().async {
                updatedMessageList.append(internalConsentFilter.applyConsents(message))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.2)
        for i in 0..<20 {
            let updatedMessage = updatedMessageList[i]
            XCTAssertNotNil(updatedMessage)
            XCTAssertNotNil(updatedMessage.integrations)
            XCTAssertEqual(updatedMessage.integrations, [:])
        }
        
        XCTAssertTrue(updatedMessageList.count == 100)
    }*/
}

class TestConsentFilter1: RSConsentFilter {
    func filterConsentedDestinations(_ destinations: [RSServerDestination]) -> [String : NSNumber]? {
        return [:]
    }
}

class TestConsentFilter2: RSConsentFilter {
    func filterConsentedDestinations(_ destinations: [RSServerDestination]) -> [String : NSNumber]? {
        return [:]
    }
}
