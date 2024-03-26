//
//  RSwatchOSLifeCycleEventTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 02/06/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

#if os(watchOS)
class RSwatchOSLifeCycleEventTests: XCTestCase {

    var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: WRITE_KEY).dataPlaneURL(DATA_PLANE_URL))
    }

    override func tearDownWithError() throws {
        client = nil
    }
    
    func testApplicationInstalled() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let watchOSLifeCyclePlugin = RSwatchOSLifecycleEvents()
        client.add(plugin: watchOSLifeCyclePlugin)
        
        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        RSUserDefaults.saveApplicationVersion(nil)
        RSUserDefaults.saveApplicationBuild(nil)
                
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        watchOSLifeCyclePlugin.applicationDidFinishLaunching(watchExtension: nil)
        
        let trackEvent = resultPlugin.trackList.first { message in
            message.event == "Application Installed"
        }
        
        XCTAssertTrue(trackEvent?.event == "Application Installed")
        XCTAssertTrue(trackEvent?.type == .track)
    }

    func testApplicationUpdated() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let watchOSLifeCyclePlugin = RSwatchOSLifecycleEvents()
        client.add(plugin: watchOSLifeCyclePlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        RSUserDefaults.saveApplicationVersion("2.0.0-beta")
        RSUserDefaults.saveApplicationBuild("2")
        
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        watchOSLifeCyclePlugin.applicationDidFinishLaunching(watchExtension: nil)
        
        let trackEvent = resultPlugin.trackList.first { message in
            message.event == "Application Updated"
        }
        
        XCTAssertTrue(trackEvent?.event == "Application Updated")
        XCTAssertTrue(trackEvent?.type == .track)
    }
        
    func testApplicationOpened() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let watchOSLifeCyclePlugin = RSwatchOSLifecycleEvents()
        client.add(plugin: watchOSLifeCyclePlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        watchOSLifeCyclePlugin.applicationWillEnterForeground(watchExtension: nil)
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        XCTAssertTrue(trackEvent?.event == "Application Opened")
        XCTAssertTrue(trackEvent?.type == .track)
    }
}
#endif
