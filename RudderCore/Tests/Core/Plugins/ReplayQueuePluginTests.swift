//
//  ReplayQueuePluginTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class ReplayQueueTests: XCTestCase {
    func test_replayQueue_withNoCachedSourceConfig_andNewSourceConfigEnabledTrue() {
        let processMessageExpectation = expectation(description: "Process 5 messages")
        processMessageExpectation.expectedFulfillmentCount = 5
        
        let updateSourceConfigExpectation = expectation(description: "Update SourceConfig")
        updateSourceConfigExpectation.expectedFulfillmentCount = 1
        
        let client = RSClientMock()

        let replayQueuePlugin = ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueueTests_1".queueLabel()))
        replayQueuePlugin.client = client
        client.addPlugin(replayQueuePlugin)
        
        let destinationPlugin = ReplayQueueTestDestination(
            onProcessMessage: processMessageExpectation.fulfill,
            onUpdateSourceConfig: updateSourceConfigExpectation.fulfill
        )
        destinationPlugin.client = client
        client.addPlugin(destinationPlugin)
        
        client.track("test_track", properties: nil, option: nil)
        client.screen("test_screen", category: nil, properties: nil, option: nil)
        client.identify("test_user_id", traits: nil, option: nil)
        client.alias("test_new_id", option: nil)
        client.group("test_group_id", traits: nil, option: nil)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: true
            )
        ))
        
        wait(for: [processMessageExpectation, updateSourceConfigExpectation], timeout: 1.0)
    }
    
    func test_replayQueue_withNoCachedSourceConfig_andNewSourceConfigEnabledFalse() {
        let processMessageExpectation = expectation(description: "Process 5 messages")
        processMessageExpectation.expectedFulfillmentCount = 5
        processMessageExpectation.isInverted = true
        
        let updateSourceConfigExpectation = expectation(description: "Update SourceConfig")
        updateSourceConfigExpectation.expectedFulfillmentCount = 1
        
        let client = RSClientMock()
        
        let replayQueuePlugin = ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueueTests_1".queueLabel()))
        replayQueuePlugin.client = client
        client.addPlugin(replayQueuePlugin)
        
        let destinationPlugin = ReplayQueueTestDestination(
            onProcessMessage: processMessageExpectation.fulfill,
            onUpdateSourceConfig: updateSourceConfigExpectation.fulfill
        )
        destinationPlugin.client = client
        client.addPlugin(destinationPlugin)
        
        client.track("test_track", properties: nil, option: nil)
        client.screen("test_screen", category: nil, properties: nil, option: nil)
        client.identify("test_user_id", traits: nil, option: nil)
        client.alias("test_new_id", option: nil)
        client.group("test_group_id", traits: nil, option: nil)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: false
            )
        ))
        
        wait(for: [processMessageExpectation, updateSourceConfigExpectation], timeout: 1.0)
    }
    
    func test_replayQueue_withCachedSourceConfigEnabledTrue_andNewSourceConfigEnabledFalse() {
        let processMessageExpectation = expectation(description: "Process 5 messages")
        processMessageExpectation.expectedFulfillmentCount = 5
        
        let updateSourceConfigExpectation = expectation(description: "Update SourceConfig 2 times")
        updateSourceConfigExpectation.expectedFulfillmentCount = 2
        
        let client = RSClientMock()
        
        let replayQueuePlugin = ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueueTests_1".queueLabel()))
        replayQueuePlugin.client = client
        client.addPlugin(replayQueuePlugin)
        
        let destinationPlugin = ReplayQueueTestDestination(
            onProcessMessage: processMessageExpectation.fulfill,
            onUpdateSourceConfig: updateSourceConfigExpectation.fulfill
        )
        destinationPlugin.client = client
        client.addPlugin(destinationPlugin)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: true
            )
        ))
        
        client.track("test_track", properties: nil, option: nil)
        client.screen("test_screen", category: nil, properties: nil, option: nil)
        client.identify("test_user_id", traits: nil, option: nil)
        client.alias("test_new_id", option: nil)
        client.group("test_group_id", traits: nil, option: nil)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: false
            )
        ))
        
        client.track("test_track_2", properties: nil, option: nil)
        client.screen("test_screen_2", category: nil, properties: nil, option: nil)
        client.identify("test_user_id_2", traits: nil, option: nil)
        client.alias("test_new_id_2", option: nil)
        client.group("test_group_id_2", traits: nil, option: nil)
        
        wait(for: [processMessageExpectation, updateSourceConfigExpectation], timeout: 1.0)
    }
    
    func test_replayQueue_withCachedSourceConfigEnabledTrue_andNewSourceConfigEnabledTrue() {
        let processMessageExpectation = expectation(description: "Process 5 messages")
        processMessageExpectation.expectedFulfillmentCount = 10
        
        let updateSourceConfigExpectation = expectation(description: "Update SourceConfig 2 times")
        updateSourceConfigExpectation.expectedFulfillmentCount = 2
        
        let client = RSClientMock()
        
        let replayQueuePlugin = ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueueTests_1".queueLabel()))
        replayQueuePlugin.client = client
        client.addPlugin(replayQueuePlugin)
        
        let destinationPlugin = ReplayQueueTestDestination(
            onProcessMessage: processMessageExpectation.fulfill,
            onUpdateSourceConfig: updateSourceConfigExpectation.fulfill
        )
        destinationPlugin.client = client
        client.addPlugin(destinationPlugin)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: true
            )
        ))
        
        client.track("test_track", properties: nil, option: nil)
        client.screen("test_screen", category: nil, properties: nil, option: nil)
        client.identify("test_user_id", traits: nil, option: nil)
        client.alias("test_new_id", option: nil)
        client.group("test_group_id", traits: nil, option: nil)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: true
            )
        ))
        
        client.track("test_track_2", properties: nil, option: nil)
        client.screen("test_screen_2", category: nil, properties: nil, option: nil)
        client.identify("test_user_id_2", traits: nil, option: nil)
        client.alias("test_new_id_2", option: nil)
        client.group("test_group_id_2", traits: nil, option: nil)
        
        wait(for: [processMessageExpectation, updateSourceConfigExpectation], timeout: 1.0)
    }
    
    func test_replayQueue_withCachedSourceConfigEnabledFalse_andNewSourceConfigEnabledTrue() {
        let processMessageExpectation = expectation(description: "Process 5 messages")
        processMessageExpectation.expectedFulfillmentCount = 5
        
        let updateSourceConfigExpectation = expectation(description: "Update SourceConfig 2 times")
        updateSourceConfigExpectation.expectedFulfillmentCount = 2
        
        let client = RSClientMock()
        
        let replayQueuePlugin = ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueueTests_1".queueLabel()))
        replayQueuePlugin.client = client
        client.addPlugin(replayQueuePlugin)
        
        let destinationPlugin = ReplayQueueTestDestination(
            onProcessMessage: processMessageExpectation.fulfill,
            onUpdateSourceConfig: updateSourceConfigExpectation.fulfill
        )
        destinationPlugin.client = client
        client.addPlugin(destinationPlugin)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: false
            )
        ))
        
        client.track("test_track", properties: nil, option: nil)
        client.screen("test_screen", category: nil, properties: nil, option: nil)
        client.identify("test_user_id", traits: nil, option: nil)
        client.alias("test_new_id", option: nil)
        client.group("test_group_id", traits: nil, option: nil)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: true
            )
        ))
        
        wait(for: [processMessageExpectation, updateSourceConfigExpectation], timeout: 1.0)
    }
    
    func test_replayQueue_withCachedSourceConfigEnabledFalse_andNewSourceConfigEnabledFalse() {
        let processMessageExpectation = expectation(description: "Process 5 messages")
        processMessageExpectation.expectedFulfillmentCount = 5
        processMessageExpectation.isInverted = true
        
        let updateSourceConfigExpectation = expectation(description: "Update SourceConfig 2 times")
        updateSourceConfigExpectation.expectedFulfillmentCount = 2
        
        let client = RSClientMock()
        
        let replayQueuePlugin = ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueueTests_1".queueLabel()))
        replayQueuePlugin.client = client
        client.addPlugin(replayQueuePlugin)
        
        let destinationPlugin = ReplayQueueTestDestination(
            onProcessMessage: processMessageExpectation.fulfill,
            onUpdateSourceConfig: updateSourceConfigExpectation.fulfill
        )
        destinationPlugin.client = client
        client.addPlugin(destinationPlugin)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: false
            )
        ))
        
        client.track("test_track", properties: nil, option: nil)
        client.screen("test_screen", category: nil, properties: nil, option: nil)
        client.identify("test_user_id", traits: nil, option: nil)
        client.alias("test_new_id", option: nil)
        client.group("test_group_id", traits: nil, option: nil)
        
        client.updateSourceConfig(.mockWith(
            source: .mockWith(
                enabled: false
            )
        ))
        
        wait(for: [processMessageExpectation, updateSourceConfigExpectation], timeout: 1.0)
    }
}

class ReplayQueueTestDestination: DestinationPlugin {
    var name: String = "test_destination"
    var plugins: [Rudder.Plugin] = []
    var type: Rudder.PluginType = .destination
    var client: RudderProtocol?
    var sourceConfig: Rudder.SourceConfig? {
        didSet {
            onUpdateSourceConfig?()
        }
    }
    
    var onProcessMessage: (() -> Void)?
    var onUpdateSourceConfig: (() -> Void)?
    
    init(onProcessMessage: (() -> Void)? = nil, onUpdateSourceConfig: (() -> Void)? = nil) {
        self.onProcessMessage = onProcessMessage
        self.onUpdateSourceConfig = onUpdateSourceConfig
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        onProcessMessage?()
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        onProcessMessage?()
        return message
    }
    
    func alias(message: AliasMessage) -> AliasMessage? {
        onProcessMessage?()
        return message
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        onProcessMessage?()
        return message
    }
    
    func group(message: GroupMessage) -> GroupMessage? {
        onProcessMessage?()
        return message
    }
}
