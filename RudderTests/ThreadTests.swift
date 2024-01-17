//
//  ThreadTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 04/05/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class ThreadTests: XCTestCase {

    /*var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        let rsConfig = RSConfig(writeKey: WRITE_KEY)
            .dataPlaneURL(DATA_PLANE_URL)
            .loglevel(.debug)
            .dbCountThreshold(20)
            .trackLifecycleEvents(true)
            .recordScreenViews(true)
        client.configure(with: rsConfig)
    }

    override func tearDownWithError() throws {
        client = nil
    }

    func test_100MainThread() {
        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for i in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.client.track("\(i)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10)
    }
    
    func test_500MainThread() {
        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for i in 0..<500 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.client.track("\(i)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 50)
    }
    
    func test_1000MainThread() {
        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for i in 0..<1000 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.client.track("\(i)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 100)
    }*/
}
