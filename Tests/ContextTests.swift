//
//  RSContextTests.swift
//  RudderTests
//
//  Created by Desu Sai Venkat on 13/03/23.
//

import Foundation
import XCTest
@testable import Rudder

class ContextTests: XCTestCase {
    
    var context: RSContext!
    var preferenceManager: RSPreferenceManager!
    var testUtils: TestUtils!
    var sampleTraits = ["firstname": "bravo", "lastname": "dwayne", "country": "westindies"]
    var user1Traits = ["userId": "1", "name" : "user1", "country": "one"]
    var user2Traits = ["userId": "2", "name" : "user2", "country": "two"]
    let externalIds1 = [
        [
            "type": "type1",
            "id": "first"
        ] as NSMutableDictionary,
        [
            "type": "type2",
            "id": "second"
        ] as NSMutableDictionary
    ] as NSMutableArray
    let externalIds2 = [
        [
            "type": "type2",
            "id": "second-updated"
        ] as NSMutableDictionary,
        [
            "type": "type3",
            "id": "three"
        ] as NSMutableDictionary
    ] as NSMutableArray
    let finalExternalIds = [
        [
            "type": "type1",
            "id": "first"
        ] as NSMutableDictionary,
        [
            "type": "type2",
            "id": "second-updated"
        ] as NSMutableDictionary,
        [
            "type": "type3",
            "id": "three"
        ] as NSMutableDictionary
    ] as NSMutableArray
    
    override func setUp() {
        super.setUp()
        preferenceManager = RSPreferenceManager.getInstance()
        preferenceManager.clearAnonymousId()
        preferenceManager.clearTraits()
        preferenceManager.clearExternalIds()
        preferenceManager.clearSessionId()
        preferenceManager.clearLastEventTimeStamp()
        preferenceManager.saveAnonymousId("testAnonymousId")
        context = RSContext()
        testUtils = TestUtils()
    }
    
    override func tearDown() {
        super.tearDown()
        context = nil;
        testUtils = nil
    }
    
    func test_resetTraits() {
        context.updateTraitsDict(NSMutableDictionary(dictionary: sampleTraits))
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: sampleTraits))
        context.resetTraits()
        XCTAssertEqual(context.traits, ["anonymousId": "testAnonymousId"])
    }
    
    func test_updateTraitsWithDiffValues() {
        let traits = RSTraits(dict: sampleTraits)
        context.updateTraits(traits);
        sampleTraits["anonymousId"] = "testAnonymousId";
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: sampleTraits))
        context.updateTraits(RSTraits(dict: ["firstname": "johnson"]))
        XCTAssertNotEqual(context.traits, NSMutableDictionary(dictionary: sampleTraits))
        sampleTraits["firstname"] = "johnson";
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: sampleTraits))
    }
    
    func test_updateTraitsWithSameUserIds() {
        let traits = RSTraits(dict:user1Traits)
        context.updateTraits(traits)
        user1Traits["anonymousId"] = "testAnonymousId";
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: user1Traits))
        context.updateTraits(RSTraits(dict: ["userId": "1", "rank": "1"]))
        user1Traits["rank"] = "1"
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: user1Traits))
    }
    
    func test_updateTraitsWithDiffUserIds() {
        let traits1 = RSTraits(dict:user1Traits)
        context.updateTraits(traits1)
        user1Traits["anonymousId"] = "testAnonymousId";
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: user1Traits))
        let traits2 = RSTraits(dict: user2Traits)
        context.updateTraits(traits2)
        user2Traits["anonymousId"] = "testAnonymousId";
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: user2Traits))
        XCTAssertEqual(context.traits["userId"] as! String, user2Traits["userId"]!)
    }
    
    func test_persistTraits() {
        let traits1 = RSTraits(dict:user1Traits)
        context.updateTraits(traits1)
        context.persistTraitsOnQueue()
        user1Traits["anonymousId"] = "testAnonymousId";
        XCTAssertEqual(testUtils.convertToDictionary(text: preferenceManager.getTraits()), user1Traits)
        context.updateTraits(RSTraits(dict: ["userId": "1", "rank": "1"]))
        context.persistTraitsOnQueue()
        user1Traits["rank"] = "1"
        XCTAssertEqual(testUtils.convertToDictionary(text: preferenceManager.getTraits()), user1Traits)
    }
    
    func test_updateTraitsDict() {
        context.updateTraitsDict(NSMutableDictionary(dictionary: user1Traits))
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: user1Traits))
        context.updateTraitsDict(NSMutableDictionary(dictionary: user2Traits))
        XCTAssertEqual(context.traits, NSMutableDictionary(dictionary: user2Traits))
    }
    
    func test_updateTraitsAnonymousId() {
        context.updateTraitsAnonymousId()
        XCTAssertEqual(context.traits["anonymousId"] as! String, "testAnonymousId")
        preferenceManager.saveAnonymousId("test1")
        context.updateTraitsAnonymousId()
        XCTAssertEqual(context.traits["anonymousId"] as! String, "test1")
        preferenceManager.saveAnonymousId("test2")
        context.updateTraitsAnonymousId()
        XCTAssertEqual(context.traits["anonymousId"] as! String, "test2")
        preferenceManager.saveAnonymousId("test3")
        context.updateTraitsAnonymousId()
        XCTAssertEqual(context.traits["anonymousId"] as! String, "test3")
    }
    
    func test_putDeviceToken() {
        context.putDeviceToken("test1")
        XCTAssertEqual(context.device.token, "test1")
        context.putDeviceToken("test2")
        XCTAssertEqual(context.device.token, "test2")
        context.putDeviceToken("test3")
        XCTAssertEqual(context.device.token, "test3")
    }
    
    func test_putAdvertisementId() {
        context.putAdvertisementId("00000000-0000-0000-0000-000000000000")
        XCTAssertEqual(context.device.advertisingId, "");
        XCTAssertFalse(context.device.adTrackingEnabled)
        context.putAdvertisementId("some-random-uuid");
        XCTAssertEqual(context.device.advertisingId, "some-random-uuid");
        XCTAssertTrue(context.device.adTrackingEnabled)
    }
    
    func test_updateExternalIds() {
        context.updateExternalIds(externalIds1)
        XCTAssertEqual(context.externalIds, externalIds1)
        context.updateExternalIds(externalIds2)
        XCTAssertEqual(context.externalIds, finalExternalIds)
    }
    
    func test_persistExternalIds() {
        context.updateExternalIds(externalIds1)
        context.persistExternalIds()
        XCTAssertEqual(preferenceManager.getExternalIds(), testUtils.convertToJSONString(arrayObject: externalIds1))
        context.updateExternalIds(externalIds2)
        context.persistExternalIds()
        XCTAssertEqual(preferenceManager.getExternalIds(), testUtils.convertToJSONString(arrayObject: finalExternalIds))
    }
    
    func test_resetExternalIds() {
        context.updateExternalIds(externalIds1)
        XCTAssertEqual(context.externalIds, externalIds1)
        context.resetExternalIdsOnQueue()
        XCTAssertNil(context.getExternalIds())
        XCTAssertNil(preferenceManager.getExternalIds())
        context.updateExternalIds(externalIds2)
        XCTAssertEqual(context.externalIds, externalIds2)
        context.resetExternalIdsOnQueue()
        XCTAssertNil(context.getExternalIds())
        XCTAssertNil(preferenceManager.getExternalIds())
    }
    
    func test_putAppTrackingConsent() {
        context.putAppTrackingConsent(-1)
        XCTAssertEqual(context.device.attTrackingStatus, RSATTNotDetermined)
        context.putAppTrackingConsent(0)
        XCTAssertEqual(context.device.attTrackingStatus, RSATTNotDetermined)
        context.putAppTrackingConsent(1)
        XCTAssertEqual(context.device.attTrackingStatus, RSATTRestricted)
        context.putAppTrackingConsent(2)
        XCTAssertEqual(context.device.attTrackingStatus, RSATTDenied)
        context.putAppTrackingConsent(3)
        XCTAssertEqual(context.device.attTrackingStatus, RSATTAuthorize)
        context.putAppTrackingConsent(4)
        XCTAssertEqual(context.device.attTrackingStatus, RSATTAuthorize)
    }
    
    func test_setSessionData() {
        let userSession = RSUserSession.initiate(RSSessionInActivityDefaultTimeOut, with: preferenceManager)
        userSession.start()
        context.setSessionData(userSession)
        XCTAssertEqual(context.sessionId, userSession.getId())
        XCTAssertTrue(context.sessionStart)
    }
    
    func test_setConsentData() {
        var deniedConsentIds = ["deniedId1", "deniedId2", "deniedId3", "deniedId4"]
        context.setConsentData(deniedConsentIds)
        XCTAssertEqual(getConsentData(), ["deniedConsentIds": deniedConsentIds])
        deniedConsentIds = ["deniedId5", "deniedId6", "deniedId7", "deniedId8"]
        context.setConsentData(deniedConsentIds)
        XCTAssertEqual(getConsentData(), ["deniedConsentIds": deniedConsentIds])
        deniedConsentIds = ["deniedId9", "deniedId10", "deniedId11", "deniedId12"]
        context.setConsentData(deniedConsentIds)
        XCTAssertEqual(getConsentData(), ["deniedConsentIds": deniedConsentIds])
    }
    
    func getConsentData() -> [String: [String]]{
        let dict = context.dict()
        let consentManagement: [String: [String]] = dict["consentManagement"] as! [String: [String]]
        return consentManagement
        
    }
}
