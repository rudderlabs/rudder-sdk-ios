//
//  UserSessionPluginTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class UserSessionPluginTests: XCTestCase {
    let userDefaultsWorker = UserDefaultsWorker(
        suiteName: #file,
        queue: DispatchQueue(label: "userSessionPluginTests".queueLabel())
    )
    
    func test_sessionId() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // When
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: true,
                autoSessionTracking: true
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        // Then
        XCTAssertNotNil(userSessionPlugin.sessionId)
    }
    
    func test_startSession_trackLifecycleEvents_false() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: false
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertNil(userSessionPlugin.sessionId)
        XCTAssertNil(trackMessage?.sessionId)
        
        // When
        userSessionPlugin.startSession()
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        // Then
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_2?.sessionId)
        XCTAssertTrue(trackMessage_2?.sessionStart ?? false)
    }
    
    func test_startSession_withID_trackLifecycleEvents_false() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: false
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertNil(userSessionPlugin.sessionId)
        XCTAssertNil(trackMessage?.sessionId)
        
        // When
        let sessionId = 1234567890
        userSessionPlugin.startSession(sessionId)
                
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        // Then
        XCTAssertEqual(userSessionPlugin.sessionId, sessionId)
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_2?.sessionId)
        XCTAssertEqual(trackMessage_2?.sessionId, sessionId)
        XCTAssertTrue(trackMessage_2?.sessionStart ?? false)
    }
    
    func test_startSession_trackLifecycleEvents_true() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: true,
                autoSessionTracking: true
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage?.sessionId)
        XCTAssertTrue(trackMessage?.sessionStart ?? false)
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_2?.sessionId)
        XCTAssertFalse(trackMessage_2?.sessionStart ?? false)
        XCTAssertEqual(trackMessage?.sessionId, trackMessage_2?.sessionId)
        
        sleep(bySeconds: 2)
        
        // When
        userSessionPlugin.startSession()
        
        let trackMessage_3 = userSessionPlugin.process(message: TrackMessage(event: "test_session_3"))
        
        // Then
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_3?.sessionId)
        XCTAssertTrue(trackMessage_3?.sessionStart ?? false)
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_3?.sessionId)
        XCTAssertNotEqual(trackMessage_2?.sessionId, trackMessage_3?.sessionId)
        
        let trackMessage_4 = userSessionPlugin.process(message: TrackMessage(event: "test_session_4"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_4?.sessionId)
        XCTAssertFalse(trackMessage_2?.sessionStart ?? false)
        XCTAssertEqual(trackMessage_3?.sessionId, trackMessage_4?.sessionId)
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_4?.sessionId)
        XCTAssertNotEqual(trackMessage_2?.sessionId, trackMessage_4?.sessionId)
    }
    
    func test_startSession_withID_trackLifecycleEvents_true() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: true,
                autoSessionTracking: true
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage?.sessionId)
        XCTAssertTrue(trackMessage?.sessionStart ?? false)
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_2?.sessionId)
        XCTAssertFalse(trackMessage_2?.sessionStart ?? false)
        XCTAssertEqual(trackMessage?.sessionId, trackMessage_2?.sessionId)
        
        // When
        let sessionId = 1234567890
        userSessionPlugin.startSession(sessionId)
        
        let trackMessage_3 = userSessionPlugin.process(message: TrackMessage(event: "test_session_3"))
        
        // Then
        XCTAssertEqual(userSessionPlugin.sessionId, sessionId)
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_3?.sessionId)
        XCTAssertTrue(trackMessage_3?.sessionStart ?? false)
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_3?.sessionId)
        XCTAssertNotEqual(trackMessage_2?.sessionId, trackMessage_3?.sessionId)
        
        let trackMessage_4 = userSessionPlugin.process(message: TrackMessage(event: "test_session_4"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_4?.sessionId)
        XCTAssertFalse(trackMessage_2?.sessionStart ?? false)
        XCTAssertEqual(trackMessage_3?.sessionId, trackMessage_4?.sessionId)
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_4?.sessionId)
        XCTAssertNotEqual(trackMessage_2?.sessionId, trackMessage_4?.sessionId)
    }
    
    func test_endSession() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: false,
                autoSessionTracking: false
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertNil(trackMessage?.sessionId)
        
        userSessionPlugin.startSession()
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        XCTAssertEqual(userSessionPlugin.sessionId, trackMessage_2?.sessionId)
        XCTAssertTrue(trackMessage_2?.sessionStart ?? false)
        
        // When
        userSessionPlugin.endSession()
        
        let trackMessage_3 = userSessionPlugin.process(message: TrackMessage(event: "test_session_3"))
        
        // Then
        XCTAssertNil(trackMessage_3?.sessionId)
    }
    
    func test_refreshSessionIfNeeded() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: true,
                autoSessionTracking: true,
                sessionTimeOut: 2000
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertNotNil(trackMessage?.sessionId)
        XCTAssertTrue(trackMessage?.sessionStart ?? false)
        
        sleep(bySeconds: 2)
        
        // When
        userSessionPlugin.refreshSessionIfNeeded()
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        // Then
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_2?.sessionId)
        XCTAssertTrue(trackMessage_2?.sessionStart ?? false)
    }
    
    func test_reset_AutomaticSessionTracking() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: true,
                autoSessionTracking: true
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertNotNil(trackMessage?.sessionId)
        XCTAssertTrue(trackMessage?.sessionStart ?? false)
                
        // When
        sleep(bySeconds: 2)
        userSessionPlugin.reset()
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        
        // Then
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_2?.sessionId)
        XCTAssertTrue(trackMessage_2?.sessionStart ?? false)
    }
    
    func test_reset_ManualSessionTracking() {
        userDefaultsWorker.userDefaults?.removePersistentDomain(forName: #file)
        
        // Given
        let userSessionPlugin = UserSessionPlugin()
        userSessionPlugin.client = RSClientMock(
            configuration: .mockWith(
                trackLifecycleEvents: false,
                autoSessionTracking: false
            ),
            userDefaultsWorker: userDefaultsWorker
        )
        
        let trackMessage = userSessionPlugin.process(message: TrackMessage(event: "test_session"))
        
        XCTAssertNil(trackMessage?.sessionId)
        
        userSessionPlugin.startSession()
        
        let trackMessage_2 = userSessionPlugin.process(message: TrackMessage(event: "test_session_2"))
        XCTAssertNotNil(trackMessage_2?.sessionId)
        XCTAssertTrue(trackMessage_2?.sessionStart ?? false)
        
        sleep(bySeconds: 2)

        // When
        userSessionPlugin.reset()
        
        let trackMessage_3 = userSessionPlugin.process(message: TrackMessage(event: "test_session_3"))
        
        // Then
        XCTAssertNotEqual(trackMessage?.sessionId, trackMessage_3?.sessionId)
        XCTAssertTrue(trackMessage_3?.sessionStart ?? false)
    }
}
