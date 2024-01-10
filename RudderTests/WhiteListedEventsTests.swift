//
//  WhiteListedEventsTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 09/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

// swiftlint:disable inclusive_language
class WhiteListedEventsTests: XCTestCase {
    
    /*var client: RSClient!
    
    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: "WRITE_KEY").dataPlaneURL("DATA_PLANE_URL"))
    }
    
    override func tearDownWithError() throws {
        client = nil
    }
    
    // swiftlint:disable inclusive_language
    // make sure you select 'Whitelist' for 'Client-side Events Filtering' section in
    // Configuration from RudderStack dashboard. It will take 5 min to be affected.
    func testWhiteListedSuccess() {
        let expectation = XCTestExpectation(description: "Firebase Expectation")
        let myDestination = FirebaseDestination {
            expectation.fulfill()
            return true
        }
        
        client.addDestination(myDestination)
        waitUntilServerConfigDownloaded(client: client)
        waitUntilStarted(client: client)
        client.track("track_whitelist_1")
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testWhiteListedFailure() {
        let expectation = XCTestExpectation(description: "Firebase Expectation")
        let myDestination = FirebaseDestination {
            expectation.fulfill()
            return true
        }
        
        client.addDestination(myDestination)
        waitUntilServerConfigDownloaded(client: client)
        waitUntilStarted(client: client)
        client.track("track_whitelist_2")
        XCTExpectFailure {
            wait(for: [expectation], timeout: 2.0)
        }
    }*/
}
