//
//  RSGroupTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class RSGroupTests: XCTestCase {

    var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }

    override func tearDownWithError() throws {
        client = nil
    }
    
    func testGroup() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.group("sample_group_id")
        
        let groupEvent = resultPlugin.lastMessage as? GroupMessage
        
        XCTAssertTrue(groupEvent?.groupId == "sample_group_id")
        XCTAssertTrue(groupEvent?.type == .group)
        XCTAssertNil(groupEvent?.traits)
        XCTAssertNil(groupEvent?.option)
    }
    
    func testGroupWithTraits() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.group("sample_group_id", traits: ["key_1": "value_1", "key_2": "value_2"])
        
        let groupEvent = resultPlugin.lastMessage as? GroupMessage
        
        XCTAssertTrue(groupEvent?.groupId == "sample_group_id")
        XCTAssertTrue(groupEvent?.type == .group)
        XCTAssertNotNil(groupEvent?.traits)
        XCTAssertNil(groupEvent?.option)
        
        let traits = groupEvent?.traits
        
        XCTAssertTrue(traits?["key_1"] == "value_1")
        XCTAssertTrue(traits?["key_2"] == "value_2")
    }
}
