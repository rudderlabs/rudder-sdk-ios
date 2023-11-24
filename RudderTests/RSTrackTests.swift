//
//  RSTrackTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class RSTrackTests: XCTestCase {
    var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }

    override func tearDownWithError() throws {
        client = nil
    }

    func testTrack() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)

        client.track("simple_track")
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackEvent?.event == "simple_track")
        XCTAssertTrue(trackEvent?.type == .track)
        XCTAssertNil(trackEvent?.properties)
        XCTAssertNil(trackEvent?.option)
    }
    
    func testTrackWithProperties() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)

        client.track("simple_track_with_props", properties: ["key_1": "value_1", "key_2": "value_2"])
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackEvent?.event == "simple_track_with_props")
        XCTAssertTrue(trackEvent?.type == .track)
        XCTAssertNotNil(trackEvent?.properties)
        XCTAssertNil(trackEvent?.option)
        
        let properties = trackEvent?.properties
        
        XCTAssertTrue(properties?["key_1"] as? String == "value_1")
        XCTAssertTrue(properties?["key_2"] as? String == "value_2")
    }
    
}
