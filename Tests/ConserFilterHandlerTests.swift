//
//  ConserFilterHandlerTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class ConserFilterHandlerTests: XCTestCase {
    
    func test_filterDestinationList_EmptyDestinationList() {
        let serverConfig = RSServerConfigSource()
        let consentFilterHandler = RSConsentFilterHandler.initiate(TestConsentFilter(), withServerConfig: serverConfig)
        
        XCTAssertTrue(serverConfig.destinations is [RSServerDestination])
        let filterDestinationList = consentFilterHandler.filterDestinationList(serverConfig.destinations as! [RSServerDestination])
        XCTAssertEqual(serverConfig.destinations as! [RSServerDestination], filterDestinationList)
    }
    
    func test_filterDestinationList() {
        let expectedDisplayNames = ["test_destination_1", "test_destination_3", "test_destination_6", "test_destination_7", "test_destination_8", "test_destination_9", "test_destination_10"]
        var serverConfig = RSServerConfigSource()
        let consentFilterHandler = getConsentFilterHandler(serverConfig: &serverConfig)
        
        XCTAssertTrue(serverConfig.destinations is [RSServerDestination])
        let filterDestinationList = consentFilterHandler.filterDestinationList(serverConfig.destinations as! [RSServerDestination])
        let filteredDisplayNames = filterDestinationList.compactMap { serverDestination in
            serverDestination.destinationDefinition.displayName
        }
        XCTAssertEqual(filteredDisplayNames, expectedDisplayNames)
    }
    
    func test_filterDestinationList_ThreadSafety() {
        let expectedDisplayNames = ["test_destination_1", "test_destination_3", "test_destination_6", "test_destination_7", "test_destination_8", "test_destination_9", "test_destination_10"]
        var serverConfig = RSServerConfigSource()
        let consentFilterHandler = getConsentFilterHandler(serverConfig: &serverConfig)
        
        XCTAssertTrue(serverConfig.destinations is [RSServerDestination])
        
        var filterDestinationList = [RSServerDestination]()
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for _ in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                filterDestinationList = consentFilterHandler.filterDestinationList(serverConfig.destinations as! [RSServerDestination])
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        let filteredDisplayNames = filterDestinationList.compactMap { serverDestination in
            serverDestination.destinationDefinition.displayName
        }
        XCTAssertEqual(filteredDisplayNames, expectedDisplayNames)
    }
    
    func test_applyConsents_EmptyDestinationList() {
        let expected = [
            "test_destination_1": true as NSObject,
            "test_destination_2": false as NSObject
        ]
        
        let options = RSOption()
        options.putIntegration("test_destination_1", isEnabled: true)
        options.putIntegration("test_destination_2", isEnabled: false)
        
        let message = RSMessageBuilder()
            .setEventName("Test Track")
            .setRSOption(options)
            .build()
        
        let serverConfig = RSServerConfigSource()
        let consentFilterHandler = RSConsentFilterHandler.initiate(TestConsentFilter(), withServerConfig: serverConfig)
        
        let updatedMessage = consentFilterHandler.applyConsents(message)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.event, "Test Track")
        XCTAssertEqual(updatedMessage.integrations, expected)
    }
    
    func test_applyConsents() {
        let expected = [
            "test_destination_1": false as NSObject,
            "test_destination_2": false as NSObject,
            "test_destination_4": false as NSObject,
            "test_destination_22": true as NSObject
        ]
        
        var serverConfig = RSServerConfigSource()
        let consentFilterHandler = getConsentFilterHandler(serverConfig: &serverConfig)
                
        let options = RSOption()
        options.putIntegration("test_destination_1", isEnabled: false)
        options.putIntegration("test_destination_2", isEnabled: true)
        options.putIntegration("test_destination_4", isEnabled: true)
        options.putIntegration("test_destination_22", isEnabled: true)
        
        let message = RSMessageBuilder()
            .setEventName("Test Track")
            .setRSOption(options)
            .build()

        let updatedMessage = consentFilterHandler.applyConsents(message)

        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.event, "Test Track")
        XCTAssertEqual(updatedMessage.integrations, expected)
    }
    
    func test_applyConsents_ThreadSafety() {
        let expected = [
            "test_destination_1": false as NSObject,
            "test_destination_2": false as NSObject,
            "test_destination_4": false as NSObject,
            "test_destination_22": true as NSObject
        ]

        var serverConfig = RSServerConfigSource()
        let consentFilterHandler = getConsentFilterHandler(serverConfig: &serverConfig)
        
        XCTAssertTrue(serverConfig.destinations is [RSServerDestination])
        
        let options = RSOption()
        options.putIntegration("test_destination_1", isEnabled: false)
        options.putIntegration("test_destination_2", isEnabled: true)
        options.putIntegration("test_destination_4", isEnabled: true)
        options.putIntegration("test_destination_22", isEnabled: true)

        let message = RSMessageBuilder()
            .setEventName("Test Track")
            .setRSOption(options)
            .build()

        var updatedMessage: RSMessage = RSMessageBuilder().build()
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for _ in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                updatedMessage = consentFilterHandler.applyConsents(message)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertNotNil(updatedMessage)
        XCTAssertEqual(updatedMessage.event, "Test Track")
        XCTAssertEqual(updatedMessage.integrations, expected)
    }
}

extension ConserFilterHandlerTests {
    func getConsentFilterHandler(serverConfig: inout RSServerConfigSource) -> RSConsentFilterHandler {
        for i in 0..<10 {
            let destination = RSServerDestination()
            destination.destinationDefinition = RSServerDestinationDefinition()
            destination.destinationDefinition.displayName = "test_destination_\(i + 1)"
            serverConfig.destinations.add(destination)
        }
        return RSConsentFilterHandler.initiate(TestConsentFilter(), withServerConfig: serverConfig)
    }
}

class TestConsentFilter: RSConsentFilter {
    func filterConsentedDestinations(_ destinations: [RSServerDestination]) -> [String: NSNumber]? {
        return ["test_destination_2": NSNumber(booleanLiteral: false), "test_destination_4": NSNumber(booleanLiteral: false), "test_destination_5": NSNumber(booleanLiteral: false)]
    }
}
