//
//  RSClientTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 07/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

let WRITE_KEY = "1wvsoF3Kx2SczQNlx1dvcqW9ODW"
let DATA_PLANE_URL = "https://rudderstacz.dataplane.rudderstack.com"

class RSClientTests: XCTestCase {
    
    var client: RSClient!
    
    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }
    
    override func tearDownWithError() throws {
        client = nil
    }
    
    func testBaseEventCreation() {
        client.track("Track 1")
    }
    
    // make sure you have Firebase added & enabled to the source in your RudderStack A/C
    func testDestinationEnabled() {
        let expectation = XCTestExpectation(description: "Firebase Expectation")
        let myDestination = FirebaseDestination {
            expectation.fulfill()
            return true
        }
        
        client.addDestination(myDestination)
        waitUntilServerConfigDownloaded(client: client)
        waitUntilStarted(client: client)
        client.track("testDestinationEnabled")
        
        wait(for: [expectation], timeout: 2.0)
    }
        
    func testDestinationNotEnabled() {
        let expectation = XCTestExpectation(description: "MyDestination Expectation")
        let myDestination = MyDestination {
            expectation.fulfill()
            return true
        }

        client.addDestination(myDestination)
        waitUntilServerConfigDownloaded(client: client)
        waitUntilStarted(client: client)
        client.track("testDestinationEnabled")

        XCTExpectFailure {
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    func testAnonymousId() {
        client.setAnonymousId("anonymous_id")
        
        let anonId = client.anonymousId
        
        XCTAssertTrue(anonId != "")
        XCTAssertTrue(anonId == "anonymous_id")
    }
    
    func testContext() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.track("context check")
        
        let context = resultPlugin.lastMessage?.context
        XCTAssertNotNil(context)
        XCTAssertNotNil(context?["screen"], "screen missing!")
        XCTAssertNotNil(context?["network"], "network missing!")
        XCTAssertNotNil(context?["os"], "os missing!")
        XCTAssertNotNil(context?["timezone"], "timezone missing!")
        XCTAssertNotNil(context?["library"], "library missing!")
        XCTAssertNotNil(context?["device"], "device missing!")
        XCTAssertNotNil(context?["app"], "app missing!")
        XCTAssertNotNil(context?["locale"], "locale missing!")
    }
    
    func testDeviceToken() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)

        client.setDeviceToken("device_token")
        client.track("device token check")
        
        let device = resultPlugin.lastMessage?.context
        let token = device?[keyPath: "device.token"] as? String
        
        XCTAssertTrue(token != "")
        XCTAssertTrue(token == "device_token")
    }
    
    func testContextTraits() {
        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let traits = client.traits
        
        XCTAssertNotNil(traits)
        XCTAssertTrue(traits?["email"] == "abc@def.com")
        XCTAssertTrue(traits?["userId"] == "user_id")
    }    
}

func waitUntilStarted(client: RSClient?) {
    guard let client = client else { return }
    if let replayQueue = client.find(pluginType: RSReplayQueuePlugin.self) {
        while replayQueue.running == true {
            RunLoop.main.run(until: Date.distantPast)
        }
    }
}

func waitUntilServerConfigDownloaded(client: RSClient?) {
    guard let client = client else { return }
    while client.serverConfig == nil {
        RunLoop.main.run(until: Date.distantPast)
    }
}

class FirebaseDestinationPlugin: RSDestinationPlugin {
    var controller: RSController = RSController()
    var client: RSClient?
    var type: PluginType = .destination
    var key: String = "Firebase"
    
    let trackCompletion: (() -> Bool)?
    
    init(trackCompletion: (() -> Bool)? = nil) {
        self.trackCompletion = trackCompletion
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        var returnEvent: TrackMessage? = message
        if let completion = trackCompletion {
            if !completion() {
                returnEvent = nil
            }
        }
        return returnEvent
    }
}

class MyDestinationPlugin: RSDestinationPlugin {
    var controller: RSController = RSController()
    var client: RSClient?
    var type: PluginType = .destination
    var key: String = "MyDestination"
    
    let trackCompletion: (() -> Bool)?
    
    init(trackCompletion: (() -> Bool)? = nil) {
        self.trackCompletion = trackCompletion
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        var returnEvent: TrackMessage? = message
        if let completion = trackCompletion {
            if !completion() {
                returnEvent = nil
            }
        }
        return returnEvent
    }
}

class FirebaseDestination: RudderDestination {
    init(trackCompletion: (() -> Bool)?) {
        super.init()
        plugin = FirebaseDestinationPlugin(trackCompletion: trackCompletion)
    }
}

class MyDestination: RudderDestination {
    init(trackCompletion: (() -> Bool)?) {
        super.init()
        plugin = MyDestinationPlugin(trackCompletion: trackCompletion)
    }
}

class ResultPlugin: RSPlugin {
    let type: PluginType = .after
    var client: RSClient?
    var lastMessage: RSMessage?
    var trackList = [TrackMessage]()
            
    func execute<T>(message: T?) -> T? where T: RSMessage {
        lastMessage = message
        if let message = message as? TrackMessage {
            trackList.append(message)
        }
        return message
    }
}
