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
    
    override func setUp() {
        super.setUp()
        
        let userDefaults = UserDefaults(suiteName: #file)
        userDefaults?.removePersistentDomain(forName: #file)
        
        if let config = Config(writeKey: WRITE_KEY, dataPlaneURL: DATA_PLANE_URL) {
            client = RSClient(
                config: config,
                storage: StorageMock(),
                userDefaults: userDefaults,
                sourceConfigDownloader: SourceConfigDownloaderMock(
                    downloadStatus: .mockWith(
                        needsRetry: false,
                        responseCode: 200
                    )
                ),
                logger: NOLogger()
            )
        }
    }
    
    override func tearDown() {
        super.tearDown()
        client = nil
    }
    
    func testAlias() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.alias("user_id")
        
        let aliasMessage1 = resultPlugin.lastMessage as? AliasMessage
        
        XCTAssertTrue(aliasMessage1?.userId == "user_id")
        XCTAssertTrue(aliasMessage1?.type == .alias)
        XCTAssertNil(aliasMessage1?.option)
        XCTAssertNil(aliasMessage1?.previousId)
        
        client.alias("new_user_id")
        
        let aliasMessage2 = resultPlugin.lastMessage as? AliasMessage
        
        XCTAssertTrue(aliasMessage2?.userId == "new_user_id")
        XCTAssertTrue(aliasMessage2?.previousId == "user_id")
        XCTAssertTrue(aliasMessage2?.type == .alias)
        XCTAssertNil(aliasMessage2?.option)
    }
    
    func testGroup() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.group("sample_group_id")
        
        let groupMessage = resultPlugin.lastMessage as? GroupMessage
        
        XCTAssertTrue(groupMessage?.groupId == "sample_group_id")
        XCTAssertTrue(groupMessage?.type == .group)
        XCTAssertNil(groupMessage?.traits)
        XCTAssertNil(groupMessage?.option)
    }
    
    func testGroupWithTraits() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.group("sample_group_id", traits: ["key_1": "value_1", "key_2": "value_2"])
        
        let groupMessage = resultPlugin.lastMessage as? GroupMessage
        
        XCTAssertTrue(groupMessage?.groupId == "sample_group_id")
        XCTAssertTrue(groupMessage?.type == .group)
        XCTAssertNotNil(groupMessage?.traits)
        XCTAssertNil(groupMessage?.option)
        
        let traits = groupMessage?.traits
        
        XCTAssertTrue(traits?["key_1"] == "value_1")
        XCTAssertTrue(traits?["key_2"] == "value_2")
    }
    
    func testIdentify() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.identify("user_id")
        
        let identifyMessage = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyMessage?.userId == "user_id")
        XCTAssertTrue(identifyMessage?.type == .identify)
    }
    
    func testIdentifyWithTraits() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyMessage = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyMessage?.userId == "user_id")
        XCTAssertTrue(identifyMessage?.type == .identify)
        
        let traits = identifyMessage?.traits
        
        XCTAssertTrue(traits?["email"] as? String == "abc@def.com")
        XCTAssertFalse(traits?["name"] as? String == "name")
    }
    
    func testUserIdAndTraitsPersistCorrectly() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyMessage = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyMessage?.userId == "user_id")
        XCTAssertTrue(identifyMessage?.type == .identify)
        
        let traits = identifyMessage?.traits
        
        XCTAssertTrue(traits?["email"] as? String == "abc@def.com")
        XCTAssertFalse(traits?["name"] as? String == "name")
        
        client.track("simple_track")
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackMessage?.userId == "user_id")
        let trackTraits = trackMessage?.context?["traits"] as? [String: Any]
        XCTAssertNotNil(trackTraits)
        XCTAssertTrue(trackTraits?["email"] as? String == "abc@def.com")
        XCTAssertTrue(trackTraits?["userId"] as? String == "user_id")
    }
    
    func testScreen() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.screen("ViewController")
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertNil(screenMessage?.category)
        XCTAssertNil(screenMessage?.option)

        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
    }
    
    func testScreen_Properties() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.screen("ViewController", properties: ["key_1": "value_1", "key_2": "value_2"])
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertNotNil(screenMessage?.properties)
        XCTAssertNil(screenMessage?.option)
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
        XCTAssertTrue(properties!["key_1"] as! String == "value_1")
        XCTAssertTrue(properties!["key_2"] as! String == "value_2")
    }

    func testScreen_Option() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        let option = MessageOption()
            .putIntegration("Destination_1", isEnabled: true)
            .putIntegration("Destination_2", isEnabled: false)
            .putCustomContext(["n_key_1": "n_value_1"], for: "key_1")

        client.screen("ViewController", option: option)
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertNil(screenMessage?.category)
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
        
        // Integration
        let integrations = screenMessage?.integrations
        XCTAssertTrue(integrations!["All"] == true)
        XCTAssertTrue(integrations!["Destination_1"] == true)
        XCTAssertTrue(integrations!["Destination_2"] == false)
        
        // Cutom context
        let context = screenMessage?.context
        XCTAssertTrue(context!["key_1"] as! [String: String] == ["n_key_1": "n_value_1"])
    }
    
    func testScreen_Option_Properties() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        let option = MessageOption()
            .putIntegration("Destination_1", isEnabled: true)
            .putIntegration("Destination_2", isEnabled: false)
            .putCustomContext(["n_key_1": "n_value_1"], for: "key_1")
        
        client.screen("ViewController", properties: ["key_3": "value_3", "key_4": "value_4"], option: option)
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertNil(screenMessage?.category)
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
        XCTAssertTrue(properties!["key_3"] as! String == "value_3")
        XCTAssertTrue(properties!["key_4"] as! String == "value_4")

        // Integration
        let integrations = screenMessage?.integrations
        XCTAssertTrue(integrations!["All"] == true)
        XCTAssertTrue(integrations!["Destination_1"] == true)
        XCTAssertTrue(integrations!["Destination_2"] == false)
        
        // Cutom context
        let context = screenMessage?.context
        XCTAssertTrue(context!["key_1"] as! [String: String] == ["n_key_1": "n_value_1"])
    }

    func testScreen_Category() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.screen("ViewController", category: "category_1")
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertTrue(screenMessage?.category == "category_1")
        XCTAssertNil(screenMessage?.option)
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
    }
    
    func testScreen_Category_Properties() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.screen("ViewController", category: "category_1", properties: ["key_3": "value_3", "key_4": "value_4"])
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertTrue(screenMessage?.category == "category_1")
        XCTAssertNil(screenMessage?.option)
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
        XCTAssertTrue(properties!["key_3"] as! String == "value_3")
        XCTAssertTrue(properties!["key_4"] as! String == "value_4")
    }
    
    func testScreen_Category_Option() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        let option = MessageOption()
            .putIntegration("Destination_1", isEnabled: true)
            .putIntegration("Destination_2", isEnabled: false)
            .putCustomContext(["n_key_1": "n_value_1"], for: "key_1")
        
        client.screen("ViewController", category: "category_1", option: option)
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertTrue(screenMessage?.category == "category_1")
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
        
        // Integration
        let integrations = screenMessage?.integrations
        XCTAssertTrue(integrations!["All"] == true)
        XCTAssertTrue(integrations!["Destination_1"] == true)
        XCTAssertTrue(integrations!["Destination_2"] == false)
        
        // Cutom context
        let context = screenMessage?.context
        XCTAssertTrue(context!["key_1"] as! [String: String] == ["n_key_1": "n_value_1"])
    }
    
    func testScreen_Category_Option_Properties() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        let option = MessageOption()
            .putIntegration("Destination_1", isEnabled: true)
            .putIntegration("Destination_2", isEnabled: false)
            .putCustomContext(["n_key_1": "n_value_1"], for: "key_1")
        
        client.screen("ViewController", category: "category_1", properties: ["key_3": "value_3", "key_4": "value_4"], option: option)
        
        let screenMessage = resultPlugin.lastMessage as? ScreenMessage
        XCTAssertTrue(screenMessage?.name == "ViewController")
        XCTAssertTrue(screenMessage?.type == .screen)
        XCTAssertTrue(screenMessage?.category == "category_1")
        
        let properties = screenMessage?.properties
        XCTAssertTrue(properties!["name"] as! String == "ViewController")
        XCTAssertTrue(properties!["key_3"] as! String == "value_3")
        XCTAssertTrue(properties!["key_4"] as! String == "value_4")
        
        // Integration
        let integrations = screenMessage?.integrations
        XCTAssertTrue(integrations!["All"] == true)
        XCTAssertTrue(integrations!["Destination_1"] == true)
        XCTAssertTrue(integrations!["Destination_2"] == false)
        
        // Cutom context
        let context = screenMessage?.context
        XCTAssertTrue(context!["key_1"] as! [String: String] == ["n_key_1": "n_value_1"])
    }

    func testTrack() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        // Track with eventName
        client.track("simple_track")
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackMessage?.event == "simple_track")
        XCTAssertTrue(trackMessage?.type == .track)
        XCTAssertNil(trackMessage?.properties)
        XCTAssertNil(trackMessage?.option)
    }
    
    // Track with eventName and properties
    func testTrack_Properties() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.track("simple_track_with_props", properties: ["key_1": "value_1", "key_2": "value_2"])
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackMessage?.event == "simple_track_with_props")
        XCTAssertTrue(trackMessage?.type == .track)
        XCTAssertNotNil(trackMessage?.properties)
        XCTAssertNil(trackMessage?.option)
        
        let properties = trackMessage?.properties
        
        XCTAssertTrue(properties?["key_1"] as? String == "value_1")
        XCTAssertTrue(properties?["key_2"] as? String == "value_2")
    }
    
    // Track with eventName and option
    func testTrack_Option() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        let option = MessageOption()
            .putIntegration("Destination_1", isEnabled: true)
            .putIntegration("Destination_2", isEnabled: false)
            .putCustomContext(["n_key_1": "n_value_1"], for: "key_1")
        
        client.track("simple_track_with_option", option: option)
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackMessage?.event == "simple_track_with_option")
        XCTAssertTrue(trackMessage?.type == .track)
        XCTAssertNil(trackMessage?.properties)
        XCTAssertNotNil(trackMessage?.option)
        
        // Integration
        let integrations = trackMessage?.integrations
        XCTAssertTrue(integrations!["All"] == true)
        XCTAssertTrue(integrations!["Destination_1"] == true)
        XCTAssertTrue(integrations!["Destination_2"] == false)
        
        // Cutom context
        let context = trackMessage?.context
        XCTAssertTrue(context!["key_1"] as! [String: String] == ["n_key_1": "n_value_1"])
    }
    
    // Track with eventName, properties and option
    func testTrack_Properties_Option() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        let option = MessageOption()
            .putIntegration("Destination_3", isEnabled: true)
            .putIntegration("Destination_4", isEnabled: false)
            .putCustomContext(["n_key_2": "n_value_2"], for: "key_2")

        client.track("simple_track_with_props_and_option", properties: ["key_3": "value_3", "key_4": "value_4"], option: option)
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        
        XCTAssertTrue(trackMessage?.event == "simple_track_with_props_and_option")
        XCTAssertTrue(trackMessage?.type == .track)
        XCTAssertNotNil(trackMessage?.properties)
        XCTAssertNotNil(trackMessage?.option)
        
        let properties = trackMessage?.properties
        
        XCTAssertTrue(properties?["key_3"] as? String == "value_3")
        XCTAssertTrue(properties?["key_4"] as? String == "value_4")

        // Integration
        let integrations = trackMessage?.integrations
        XCTAssertTrue(integrations!["All"] == true)
        XCTAssertTrue(integrations!["Destination_3"] == true)
        XCTAssertTrue(integrations!["Destination_4"] == false)
        
        // Cutom context
        let context = trackMessage?.context
        XCTAssertTrue(context!["key_2"] as! [String: String] == ["n_key_2": "n_value_2"])
    }
    
    // make sure you have Firebase added & enabled to the source in your RudderStack A/C
    /*func testDestinationEnabled() {
        let expectation = XCTestExpectation(description: "Firebase Expectation")
        let myDestination = FirebaseDestination {
            expectation.fulfill()
            return true
        }
        
        client.addDestination(myDestination)
        
        
        
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
        
        
        client.track("testDestinationEnabled")

        XCTExpectFailure {
            wait(for: [expectation], timeout: 2.0)
        }
    }*/
    
    func testAnonymousId() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.setAnonymousId("anonymous_id")
        
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
        client.addPlugin(resultPlugin)
        
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
        client.addPlugin(resultPlugin)

        client.setDeviceToken("device_token")
        client.track("device token check")
        
        let context = resultPlugin.lastMessage?.context
        let token = context?[keyPath: "device.token"] as? String
        
        XCTAssertTrue(token != "")
        XCTAssertTrue(token == "device_token")
    }
    
    func testTraits() {
        let resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
        
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyMessage = resultPlugin.lastMessage as? IdentifyMessage
        XCTAssertTrue(identifyMessage?.userId == "user_id")
        let identifyTraits = identifyMessage?.traits
        XCTAssertTrue(identifyTraits?["email"] as? String == "abc@def.com")
        
        client.track("test context")
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        XCTAssertTrue(trackMessage?.userId == "user_id")
        let trackTraits = trackMessage?.context?["traits"] as? [String: Any]
        XCTAssertNotNil(trackTraits)
        XCTAssertTrue(trackTraits?["email"] as? String == "abc@def.com")
        XCTAssertTrue(trackTraits?["userId"] as? String == "user_id")
        
        let clientTraits = client.traits
        XCTAssertNotNil(clientTraits)
        XCTAssertTrue(clientTraits?["email"] as? String == "abc@def.com")
        XCTAssertTrue(clientTraits?["userId"] as? String == "user_id")
    }
    
    func testUserId() {
        
    }
    
    func testConfiguration() {
        
    }
    
    func testOption() {
        
    }
    
    func testAdvertisingId() {
        
    }
    
    func testAppTrackingConsent() {
        
    }
    
    func testOptOut() {
        
    }
}

class ResultPlugin: Plugin {
    var sourceConfig: SourceConfig?
    var type: PluginType = .default
    var client: RSClient?
    
    var lastMessage: Message?
    var trackList = [TrackMessage]()
    var identifyList = [IdentifyMessage]()
    
    func process<T>(message: T?) -> T? where T: Message {
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

class ClientMockURLProtocol: URLProtocol {
        
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
}
