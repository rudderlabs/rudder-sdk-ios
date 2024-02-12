//
//  EventFilteringTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
import RudderInternal
@testable import Rudder

final class EventFilteringTests: XCTestCase {
    func test_whiteListEvent() throws {
        let destination = EventFilteringTestDestination()
        // Given
        let config = try JSON([
            "whitelistedEvents": [
                [
                    "eventName": "whitelist_1"
                ]
            ],
            "eventFilteringOption": "whitelistedEvents"

        ])
        destination.sourceConfig = .mockWith(
            source: .mockWith(
                destinations: [.mockWith(
                    config: config,
                    enabled: true,
                    destinationDefinition: .mockWith(
                        displayName: "test_destination"
                    )
                )]
            )
        )
        
        // When & Then
        _ = destination.process(message: TrackMessage(event: "whitelist_1"))
        XCTAssertNotNil(destination.lastMessage)
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_1")
        
        _ = destination.process(message: TrackMessage(event: "whitelist_2"))
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_1")
        
        _ = destination.process(message: TrackMessage(event: "whitelist_3"))
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_1")
    }
    
    func test_blackListEvent() throws {
        let destination = EventFilteringTestDestination()
        // Given
        let config = try JSON([
            "blacklistedEvents": [
                [
                    "eventName": "blacklist_1"
                ]
            ],
            "eventFilteringOption": "blacklistedEvents"
            
        ])
        destination.sourceConfig = .mockWith(
            source: .mockWith(
                destinations: [.mockWith(
                    config: config,
                    enabled: true,
                    destinationDefinition: .mockWith(
                        displayName: "test_destination"
                    )
                )]
            )
        )
        
        // When & Then
        _ = destination.process(message: TrackMessage(event: "whitelist_1"))
        XCTAssertNotNil(destination.lastMessage)
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_1")
        
        _ = destination.process(message: TrackMessage(event: "blacklist_1"))
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_1")
        
        _ = destination.process(message: TrackMessage(event: "whitelist_3"))
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_3")
    }
    
    func test_disabled() throws {
        let destination = EventFilteringTestDestination()
        // Given
        let config = try JSON([
            "blacklistedEvents": [
                [
                    "eventName": "blacklist_1"
                ]
            ],
            "whitelistedEvents": [
                [
                    "eventName": "whitelist_1"
                ]
            ],
            "eventFilteringOption": "disabled"
        ])
        destination.sourceConfig = .mockWith(
            source: .mockWith(
                destinations: [.mockWith(
                    config: config,
                    enabled: true,
                    destinationDefinition: .mockWith(
                        displayName: "test_destination"
                    )
                )]
            )
        )
        
        // When & Then
        _ = destination.process(message: TrackMessage(event: "whitelist_1"))
        XCTAssertNotNil(destination.lastMessage)
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_1")
        
        _ = destination.process(message: TrackMessage(event: "blacklist_1"))
        XCTAssertEqual(destination.lastMessage?.event, "blacklist_1")
        
        _ = destination.process(message: TrackMessage(event: "whitelist_3"))
        XCTAssertEqual(destination.lastMessage?.event, "whitelist_3")
    }
}

class EventFilteringTestDestination: DestinationPlugin {
    var name: String = "test_destination"
    var plugins: [Rudder.Plugin] = []
    var type: Rudder.PluginType = .destination
    var client: Rudder.RudderProtocol?
    var sourceConfig: Rudder.SourceConfig?
    
    var lastMessage: TrackMessage?
    
    func track(message: TrackMessage) -> TrackMessage? {
        lastMessage = message
        return message
    }
}
