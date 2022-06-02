//
//  RSIdentifyTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class RSIdentifyTests: XCTestCase {

    var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }

    override func tearDownWithError() throws {
        client = nil
    }
    
    func testIdentify() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.identify("user_id")
        
        let identifyEvent = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyEvent?.userId == "user_id")
        XCTAssertTrue(identifyEvent?.type == .identify)
    }
    
    func testIdentifyWithTraits() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyEvent = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyEvent?.userId == "user_id")
        XCTAssertTrue(identifyEvent?.type == .identify)
        
        let traits = identifyEvent?.traits
        
        XCTAssertTrue(traits?["email"] as? String == "abc@def.com")
        XCTAssertFalse(traits?["name"] as? String == "name")
    }
    
    func testUserIdAndTraitsPersistCorrectly() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyEvent = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyEvent?.userId == "user_id")
        XCTAssertTrue(identifyEvent?.type == .identify)
        
        let traits = identifyEvent?.traits
        
        XCTAssertTrue(traits?["email"] as? String == "abc@def.com")
        XCTAssertFalse(traits?["name"] as? String == "name")
        
        client.track("simple_track")
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackEvent?.userId == "user_id")
        let trackTraits = trackEvent?.context?["traits"] as? [String: Any]
        XCTAssertNil(trackTraits)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
