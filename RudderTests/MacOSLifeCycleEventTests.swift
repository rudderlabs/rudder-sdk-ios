//
//  MacOSLifeCycleEventTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 02/06/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

#if os(macOS)
class MacOSLifeCycleEventTests: XCTestCase {

    var client: RSClient!

    override func setUpWithError() throws {
        client = RSClient.sharedInstance()
        client.configure(with: RSConfig(writeKey: "WRITE_KEY", dataPlaneURL: "DATA_PLANE_URL")
            .downloadServerConfig(TestDownloadServerConfig()))
    }

    override func tearDownWithError() throws {
        client = nil
    }
    
    func testApplicationInstalled() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let macOSLifeCyclePlugin = RSmacOSLifecycleEvents()
        client.add(plugin: macOSLifeCyclePlugin)
        
        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.userDefaults?.write(application: .version, value: nil)
        client.userDefaults?.write(application: .build, value: nil)
                
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        macOSLifeCyclePlugin.application(didFinishLaunchingWithOptions: nil)
        
        let trackEvent = resultPlugin.trackList.first { message in
            message.event == "Application Installed"
        }
        
        XCTAssertTrue(trackEvent?.event == "Application Installed")
        XCTAssertTrue(trackEvent?.type == .track)
    }

    func testApplicationUpdated() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let macOSLifeCyclePlugin = RSmacOSLifecycleEvents()
        client.add(plugin: macOSLifeCyclePlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        client.userDefaults?.write(application: .version, value: "2.0.0")
        client.userDefaults?.write(application: .build, value: "2")
        
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        macOSLifeCyclePlugin.application(didFinishLaunchingWithOptions: nil)
        
        let trackEvent = resultPlugin.trackList.first { message in
            message.event == "Application Updated"
        }
        
        XCTAssertTrue(trackEvent?.event == "Application Updated")
        XCTAssertTrue(trackEvent?.type == .track)
    }
        
    func testApplicationOpened() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let macOSLifeCyclePlugin = RSmacOSLifecycleEvents()
        client.add(plugin: macOSLifeCyclePlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        macOSLifeCyclePlugin.application(didFinishLaunchingWithOptions: nil)
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        XCTAssertTrue(trackEvent?.event == "Application Opened")
        XCTAssertTrue(trackEvent?.type == .track)
    }
    
    func testApplicationTerminated() {
        let resultPlugin = ResultPlugin()
        client.add(plugin: resultPlugin)
        
        let macOSLifeCyclePlugin = RSmacOSLifecycleEvents()
        client.add(plugin: macOSLifeCyclePlugin)

        waitUntilStarted(client: client)
        waitUntilServerConfigDownloaded(client: client)
        
        macOSLifeCyclePlugin.applicationWillTerminate()
        
        let trackEvent = resultPlugin.lastMessage as? TrackMessage
        XCTAssertTrue(trackEvent?.event == "Application Terminated")
        XCTAssertTrue(trackEvent?.type == .track)
    }
}
#endif
