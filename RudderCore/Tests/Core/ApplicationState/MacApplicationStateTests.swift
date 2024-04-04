//
//  MacApplicationStateTests.swift
//  RudderTests-macOS
//
//  Created by Pallab Maiti on 19/02/24.
//

import XCTest
@testable import Rudder

#if os(macOS)

import Cocoa

final class MacApplicationStateTests: XCTestCase {
    let notificationCenter = NotificationCenter()
    let notifications = [
        NSApplication.didFinishLaunchingNotification,
        NSApplication.didResignActiveNotification,
        NSApplication.didBecomeActiveNotification
    ]
    var userDefaultsWorker: UserDefaultsWorker!
    var applicationState: ApplicationState!
    
    override func setUp() {
        super.setUp()
        let mockBundle: Bundle = .mockWith(
            bundleIdentifier: "com.rudder.mac.test",
            CFBundleVersion: "2",
            CFBundleShortVersionString: "1.0.1"
        )
        let userDefaults = UserDefaults(suiteName: #file)
        userDefaults?.removePersistentDomain(forName: #file)
        userDefaultsWorker = UserDefaultsWorker(
            userDefaults: userDefaults,
            queue: DispatchQueue(
                label: "phoneApplicationStateTests".queueLabel()
            )
        )
        let phoneApplication = MacApplicationState(
            application: NSApplication.shared,
            userDefaultsWorker: userDefaultsWorker,
            bundle: mockBundle
        )
        
        applicationState = ApplicationState(notificationCenter: notificationCenter, application: phoneApplication, notifications: notifications)
        applicationState.observeNotifications()
    }
    
    func test_ApplicationInstalled() {
        let expectation = expectation(description: "Application Installed")
        expectation.expectedFulfillmentCount = 1
        
        applicationState.trackApplicationStateMessage = { message in
            switch message.state {
                case .installed:
                    expectation.fulfill()
                default:
                    break
            }
            
        }
        
        notificationCenter.post(name: NSApplication.didFinishLaunchingNotification, object: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_ApplicationUpdated() {
        userDefaultsWorker.write(.build, value: "1")
        userDefaultsWorker.write(.version, value: "1.0.0")
        let expectation = expectation(description: "Application Updated")
        expectation.expectedFulfillmentCount = 1
        
        applicationState.trackApplicationStateMessage = { message in
            switch message.state {
                case .updated:
                    expectation.fulfill()
                default:
                    break
            }
        }
        
        notificationCenter.post(name: NSApplication.didFinishLaunchingNotification, object: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_ApplicationBackgrounded() {
        let expectation = expectation(description: "Application Backgrounded")
        expectation.expectedFulfillmentCount = 1
        
        applicationState.trackApplicationStateMessage = { message in
            switch message.state {
                case .backgrounded:
                    expectation.fulfill()
                default:
                    break
            }
        }
        
        notificationCenter.post(name: NSApplication.didResignActiveNotification, object: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_ApplicationOpened_NotFromBackground() {
        let expectation = expectation(description: "Application Opened not from background")
        expectation.expectedFulfillmentCount = 1
        
        applicationState.trackApplicationStateMessage = { message in
            switch message.state {
                case .opened:
                    do {
                        let fromBackground = try XCTUnwrap(message.properties?["from_background"] as? Bool)
                        XCTAssertFalse(fromBackground)
                        expectation.fulfill()
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                default:
                    break
            }
            
        }
        
        notificationCenter.post(name: NSApplication.didBecomeActiveNotification, object: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_ApplicationOpened_FromBackground() {
        let expectation = expectation(description: "Application Opened from background")
        expectation.expectedFulfillmentCount = 2
        
        applicationState.trackApplicationStateMessage = { message in
            switch message.state {
                case .backgrounded:
                    expectation.fulfill()
                case .opened:
                    do {
                        let fromBackground = try XCTUnwrap(message.properties?["from_background"] as? Bool)
                        XCTAssertTrue(fromBackground)
                        expectation.fulfill()
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                default:
                    break
            }
        }
        
        notificationCenter.post(name: NSApplication.didResignActiveNotification, object: nil)
        notificationCenter.post(name: NSApplication.didBecomeActiveNotification, object: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
}

#endif
