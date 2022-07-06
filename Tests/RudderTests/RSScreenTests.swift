//
//  RSScreenTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class RSScreenTests: XCTestCase {

    var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }

    override func tearDownWithError() throws {
        client = nil
    }
    
    func testScreen() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)

        client.screen("ViewController")
        
        let screenEvent = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenEvent?.name == "ViewController")
        XCTAssertTrue(screenEvent?.type == .screen)
    }
    
    func testScreenWithProperties() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)

        client.screen("ViewController", properties: ["key_1": "value_1", "key_2": "value_2"])
        
        let screenEvent = resultPlugin.lastMessage as? ScreenMessage
        
        XCTAssertTrue(screenEvent?.name == "ViewController")
        XCTAssertTrue(screenEvent?.type == .screen)
        XCTAssertNotNil(screenEvent?.properties)
        XCTAssertNil(screenEvent?.option)
        
        let properties = screenEvent?.properties
        
        XCTAssertTrue(properties?["key_1"] as? String == "value_1")
        XCTAssertTrue(properties?["key_2"] as? String == "value_2")
    }
}
