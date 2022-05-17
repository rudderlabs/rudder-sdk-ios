//
//  RSAliasTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import RudderStack

class RSAliasTests: XCTestCase {
    
    var client: RSClient!
    
    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }
    
    override func tearDownWithError() throws {
        client = nil
    }
    
    func testAlias() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.alias("user_id")
        
        let aliasEvent1 = resultPlugin.lastMessage as? AliasMessage
        
        XCTAssertTrue(aliasEvent1?.userId == "user_id")
        XCTAssertTrue(aliasEvent1?.type == .alias)
        XCTAssertNil(aliasEvent1?.option)
        XCTAssertNil(aliasEvent1?.previousId)
        
        client.alias("new_user_id")
        
        let aliasEvent2 = resultPlugin.lastMessage as? AliasMessage
        
        XCTAssertTrue(aliasEvent2?.userId == "new_user_id")
        XCTAssertTrue(aliasEvent2?.previousId == "user_id")
        XCTAssertTrue(aliasEvent2?.type == .alias)
        XCTAssertNil(aliasEvent2?.option)
    }    
}
