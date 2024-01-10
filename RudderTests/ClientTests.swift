//
//  ClientTests.swift
//  RudderStackTests
//
//  Created by Pallab Maiti on 07/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

class ClientTests: XCTestCase {
    
    var client: RSClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        client = RSClient.sharedInstance()
        let userDefaults = UserDefaults(suiteName: #file) ?? UserDefaults.standard
        userDefaults.removePersistentDomain(forName: #file)
        
        client.configure(with: RSConfig(writeKey: "WRITE_KEY", dataPlaneURL: "DATA_PLANE_URL")
            .downloadServerConfig(TestDownloadServerConfig())
            .userDefaults(RSUserDefaults(userDefaults: userDefaults)))
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        client = nil
    }
    
    func testAlias() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
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
    
    func testGroup() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
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
    
    func testIdentify() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
        client.identify("user_id")
        
        let identifyEvent = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyEvent?.userId == "user_id")
        XCTAssertTrue(identifyEvent?.type == .identify)
    }
    
    func testIdentifyWithTraits() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
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
        XCTAssertNotNil(trackTraits)
        XCTAssertTrue(trackTraits?["email"] as? String == "abc@def.com")
        XCTAssertTrue(trackTraits?["userId"] as? String == "user_id")
    }
    
    func testScreen() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
        client.screen("ViewController")
        
        let screenEvent = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenEvent?.name == "ViewController")
        XCTAssertTrue(screenEvent?.type == .screen)
    }
    
    func testScreenWithProperties() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
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
    
    func testTrack() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
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
    
    // make sure you have Firebase added & enabled to the source in your RudderStack A/C
    /*func testDestinationEnabled() {
        let expectation = XCTestExpectation(description: "Firebase Expectation")
        let myDestination = FirebaseDestination {
            expectation.fulfill()
            return true
        }
        
        client.addDestination(myDestination)
        
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
        
        waitUntilStarted(client: client)
        client.track("testDestinationEnabled")

        XCTExpectFailure {
            wait(for: [expectation], timeout: 2.0)
        }
    }*/
    
    func testAnonymousId() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        client.setAnonymousId("anonymous_id")
        
        waitUntilStarted(client: client)
        
        client.track("test_anonymous_id")
        
        let anonId = client.anonymousId
        
        XCTAssertTrue(anonId != "")
        XCTAssertTrue(anonId == "anonymous_id")
        
        let anonymousId = resultPlugin.lastMessage?.anonymousId
        
        XCTAssertTrue(anonymousId != "")
        XCTAssertTrue(anonymousId == "anonymous_id")
    }
    
    func testContext() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)

        waitUntilStarted(client: client)
        
        
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
        

        client.setDeviceToken("device_token")
        client.track("device token check")
        
        let context = resultPlugin.lastMessage?.context
        let token = context?[keyPath: "device.token"] as? String
        
        XCTAssertTrue(token != "")
        XCTAssertTrue(token == "device_token")
    }
    
    func testContextTraits() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        waitUntilStarted(client: client)
        
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyEvent = resultPlugin.lastMessage as? IdentifyMessage
        XCTAssertTrue(identifyEvent?.userId == "user_id")
        let identifyTraits = identifyEvent?.traits
        XCTAssertTrue(identifyTraits?["email"] as? String == "abc@def.com")
        
        client.track("test context")
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        XCTAssertTrue(trackEvent?.userId == "user_id")
        let trackTraits = trackEvent?.context?["traits"] as? [String: Any]
        XCTAssertNotNil(trackTraits)
        XCTAssertTrue(trackTraits?["email"] as? String == "abc@def.com")
        XCTAssertTrue(trackTraits?["userId"] as? String == "user_id")
        
        let clientTraits = client.traits
        XCTAssertNotNil(clientTraits)
        XCTAssertTrue(clientTraits?["email"] as? String == "abc@def.com")
        XCTAssertTrue(clientTraits?["userId"] as? String == "user_id")
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
    var identifyList = [IdentifyMessage]()
            
    func execute<T>(message: T?) -> T? where T: RSMessage {
        lastMessage = message
        if let message = message as? TrackMessage {
            trackList.append(message)
        }
        if let message = message as? IdentifyMessage {
            identifyList.append(message)
        }
        return message
    }
}

class TestDownloadServerConfig: RSDownloadServerConfig {
    func downloadServerConfig(retryCount: Int, completion: @escaping (Rudder.RSServerConfig?) -> Void) {
        let path = TestUtils.shared.getPath(forResource: "ServerConfig", ofType: "json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let serverConfig = try JSONDecoder().decode(RSServerConfig.self, from: data)
            completion(serverConfig)
        } catch {
            completion(nil)
        }
    }
}
