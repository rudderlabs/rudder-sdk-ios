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
    var configuration: Configuration!
    var resultPlugin: ResultPlugin!
    
    override func setUp() {
        super.setUp()
        
        let userDefaults = UserDefaults(suiteName: #file)
        userDefaults?.removePersistentDomain(forName: #file)
        
        configuration = .mockWith(
            writeKey: "1234567",
            dataPlaneURL: "https://www.rudder.dataplane.com",
            flushQueueSize: 12,
            dbCountThreshold: 20,
            sleepTimeOut: 15,
            logLevel: .error,
            trackLifecycleEvents: true,
            recordScreenViews: false,
            controlPlaneURL: "https://www.rudder.controlplane.com",
            autoSessionTracking: false,
            sessionTimeOut: 5000,
            gzipEnabled: false,
            dataResidencyServer: .EU
        )
        
        client = .mockWith(
            configuration: configuration,
            userDefaults: userDefaults
        )
        
        resultPlugin = ResultPlugin()
        client.addPlugin(resultPlugin)
    }
    
    override func tearDown() {
        super.tearDown()
        client = nil
    }
    
    func testAlias() {
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
        client.group("sample_group_id")
        
        let groupMessage = resultPlugin.lastMessage as? GroupMessage
        
        XCTAssertTrue(groupMessage?.groupId == "sample_group_id")
        XCTAssertTrue(groupMessage?.type == .group)
        XCTAssertNil(groupMessage?.traits)
        XCTAssertNil(groupMessage?.option)
    }
    
    func testGroupWithTraits() {
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
        client.identify("user_id")
        
        let identifyMessage = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyMessage?.userId == "user_id")
        XCTAssertTrue(identifyMessage?.type == .identify)
    }
    
    func testIdentifyWithTraits() {
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        let identifyMessage = resultPlugin.lastMessage as? IdentifyMessage
        
        XCTAssertTrue(identifyMessage?.userId == "user_id")
        XCTAssertTrue(identifyMessage?.type == .identify)
        
        let traits = identifyMessage?.traits
        
        XCTAssertTrue(traits?["email"] as? String == "abc@def.com")
        XCTAssertFalse(traits?["name"] as? String == "name")
    }
    
    func testUserIdAndTraitsPersistCorrectly() {
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
        let option = MessageOption()
            .putIntegrationStatus("Destination_1", isEnabled: true)
            .putIntegrationStatus("Destination_2", isEnabled: false)
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
        let option = MessageOption()
            .putIntegrationStatus("Destination_1", isEnabled: true)
            .putIntegrationStatus("Destination_2", isEnabled: false)
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
        let option = MessageOption()
            .putIntegrationStatus("Destination_1", isEnabled: true)
            .putIntegrationStatus("Destination_2", isEnabled: false)
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
        let option = MessageOption()
            .putIntegrationStatus("Destination_1", isEnabled: true)
            .putIntegrationStatus("Destination_2", isEnabled: false)
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
        let option = MessageOption()
            .putIntegrationStatus("Destination_1", isEnabled: true)
            .putIntegrationStatus("Destination_2", isEnabled: false)
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
        let option = MessageOption()
            .putIntegrationStatus("Destination_3", isEnabled: true)
            .putIntegrationStatus("Destination_4", isEnabled: false)
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
    
    func testAnonymousId() {
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
        client.setDeviceToken("device_token")
        client.track("device token check")
        
        let context = resultPlugin.lastMessage?.context
        let token = context?[keyPath: "device.token"] as? String
        
        XCTAssertTrue(token != "")
        XCTAssertTrue(token == "device_token")
    }
    
    func testTraits() {
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
        client.identify("user_id", traits: ["email": "abc@def.com"])
        
        XCTAssertEqual(client.userId, "user_id")
    }
    
    func testConfiguration() {
        let config = client.configuration
        
        XCTAssertEqual(config.writeKey, configuration.writeKey)
        XCTAssertEqual(config.dataPlaneURL, configuration.dataPlaneURL)
        XCTAssertEqual(config.flushQueueSize, configuration.flushQueueSize)
        XCTAssertEqual(config.dbCountThreshold, configuration.dbCountThreshold)
        XCTAssertEqual(config.sleepTimeOut, configuration.sleepTimeOut)
        XCTAssertEqual(config.logLevel, configuration.logLevel)
        XCTAssertEqual(config.trackLifecycleEvents, configuration.trackLifecycleEvents)
        XCTAssertEqual(config.recordScreenViews, configuration.recordScreenViews)
        XCTAssertEqual(config.controlPlaneURL, configuration.controlPlaneURL)
        XCTAssertEqual(config.automaticSessionTracking, configuration.automaticSessionTracking)
        XCTAssertEqual(config.sessionTimeOut, configuration.sessionTimeOut)
        XCTAssertEqual(config.gzipEnabled, configuration.gzipEnabled)
        XCTAssertEqual(config.dataResidencyServer, configuration.dataResidencyServer)
    }
    
    func testOption() throws {
        let globalOption = MessageOption()
            .putIntegrationStatus("destination_1", isEnabled: true)
            .putIntegrationStatus("destination_2", isEnabled: true)
            .putIntegrationStatus("destination_3", isEnabled: false)
            
        client.setGlobalOption(globalOption)
        
        client.track("test_track")
        
        let trackMessage = resultPlugin.lastMessage as? TrackMessage
        
        let integrations = try XCTUnwrap(trackMessage?.integrations)
        XCTAssertEqual(integrations["destination_1"], true)
        XCTAssertEqual(integrations["destination_2"], true)
        XCTAssertEqual(integrations["destination_3"], false)
    }
    
    func testAdvertisingId() throws {
        client.setAdvertisingId("advertising_id")
        client.track("advertising id check")
        
        let context = resultPlugin.lastMessage?.context
        let advertisingId = context?[keyPath: "device.advertisingId"] as? String
        let adTrackingEnabled = try XCTUnwrap(context?[keyPath: "device.adTrackingEnabled"] as? Bool)
        
        XCTAssertTrue(advertisingId == "advertising_id")
        XCTAssertTrue(adTrackingEnabled)
    }
    
    func testAppTrackingConsent() throws {
        client.setAppTrackingConsent(.authorize)
        client.track("advertising id check")
        
        let context = resultPlugin.lastMessage?.context
        let attTrackingStatus = try XCTUnwrap(context?[keyPath: "device.attTrackingStatus"] as? Int)
        
        XCTAssertEqual(attTrackingStatus, 3)
    }
    
    func testOptOut() {
        
    }
}

class ResultPlugin: Plugin {
    var sourceConfig: SourceConfig?
    var type: PluginType = .default
    var client: RSClientProtocol?
    
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
