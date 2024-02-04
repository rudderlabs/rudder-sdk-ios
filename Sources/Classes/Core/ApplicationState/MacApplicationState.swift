//
//  MacApplicationState.swift
//  Rudder
//
//  Created by Pallab Maiti on 29/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

#if os(macOS)

import Cocoa

class MacApplicationState: ApplicationStateProtocol {
    let application: NSApplication
    let userDefaults: UserDefaultsWorkerProtocol
    
    var trackApplicationStateMessage: ((ApplicationStateMessage) -> Void) = { _  in }
    var refreshSessionIfNeeded: (() -> Void) = { }
    
    @ReadWriteLock private var didFinishLaunching = false
    @ReadWriteLock private var fromBackground = false

    init(application: NSApplication, userDefaults: UserDefaultsWorkerProtocol) {
        self.application = application
        self.userDefaults = userDefaults
    }
    
    func didEnterBackground(notification: NSNotification) {
        fromBackground = true
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .backgrounded
        ))
    }
    
    func didFinishLaunching(notification: NSNotification) {
        didFinishLaunching = true
        
        let previousVersion: String? = userDefaults.read( .version)
        let previousBuild: String? = userDefaults.read( .build)
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if previousVersion == nil {
            trackApplicationStateMessage(ApplicationStateMessage(
                state: .installed,
                properties: Utility.getLifeCycleProperties(
                    currentVersion: currentVersion,
                    currentBuild: currentBuild
                )
            ))
        } else if currentVersion != previousVersion {
            trackApplicationStateMessage(ApplicationStateMessage(
                state: .updated,
                properties: Utility.getLifeCycleProperties(
                    previousVersion: previousVersion,
                    previousBuild: previousBuild,
                    currentVersion: currentVersion,
                    currentBuild: currentBuild
                )
            ))
        }
        
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .opened,
            properties: Utility.getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                fromBackground: false
            )
        ))
        
        userDefaults.write(.version, value: currentVersion)
        userDefaults.write(.build, value: currentBuild)
    }
    
    func didBecomeActive(notification: NSNotification) {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if !didFinishLaunching {
            didFinishLaunching = true
            
            let previousVersion: String? = userDefaults.read( .version)
            let previousBuild: String? = userDefaults.read( .build)
            
            if previousVersion == nil {
                trackApplicationStateMessage(ApplicationStateMessage(
                    state: .installed,
                    properties: Utility.getLifeCycleProperties(
                        currentVersion: currentVersion,
                        currentBuild: currentBuild
                    )
                ))
            } else if currentVersion != previousVersion {
                trackApplicationStateMessage(ApplicationStateMessage(
                    state: .updated,
                    properties: Utility.getLifeCycleProperties(
                        previousVersion: previousVersion,
                        previousBuild: previousBuild,
                        currentVersion: currentVersion,
                        currentBuild: currentBuild
                    )
                ))
            }
            
            userDefaults.write(.version, value: currentVersion)
            userDefaults.write(.build, value: currentBuild)
        }
        
        if fromBackground {
            refreshSessionIfNeeded()
        }
        
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .opened,
            properties: Utility.getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                fromBackground: fromBackground
            )
        ))
    }
}

extension Notification.Name {
    func convert() -> NotificationName {
        switch self {
        case NSApplication.didResignActiveNotification:
            return .didEnterBackground
        case NSApplication.didFinishLaunchingNotification:
            return .didFinishLaunching
        case NSApplication.didBecomeActiveNotification:
            return .didBecomeActive
        default:
            return .unknown
        }
    }
}

extension ApplicationState {
    static func current(
        notificationCenter: NotificationCenter,
        application: NSApplication = NSApplication.shared,
        userDefaults: UserDefaultsWorkerProtocol,
        notifications: [Notification.Name] = [
            NSApplication.didFinishLaunchingNotification,
            NSApplication.didResignActiveNotification,
            NSApplication.didBecomeActiveNotification
        ]
    ) -> Self {
        self.init(
            notificationCenter: notificationCenter,
            application: MacApplicationState(
                application: application,
                userDefaults: userDefaults
            ),
            notifications: notifications
        )
    }
}

#endif
