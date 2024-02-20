//
//  MacApplicationState.swift
//  Rudder
//
//  Created by Pallab Maiti on 29/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

#if os(macOS)

import Cocoa

class MacApplicationState: ApplicationStateProtocol {
    let application: NSApplication
    let userDefaultsWorker: UserDefaultsWorkerProtocol
    let bundle: Bundle
    
    var currentVersion: String? {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    var currentBuild: String? {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    var previousVersion: String? {
        userDefaultsWorker.read(.version)
    }
    var previousBuild: String? {
        userDefaultsWorker.read(.build)
    }
    
    var trackApplicationStateMessage: ((ApplicationStateMessage) -> Void) = { _  in }
    var refreshSessionIfNeeded: (() -> Void) = { }
    
    @ReadWriteLock private var didFinishLaunching = false
    @ReadWriteLock private var isBackgrounded = false
    
    init(application: NSApplication, userDefaultsWorker: UserDefaultsWorkerProtocol, bundle: Bundle = Bundle.main) {
        self.application = application
        self.userDefaultsWorker = userDefaultsWorker
        self.bundle = bundle
    }
    
    func didEnterBackground(notification: NSNotification) {
        isBackgrounded = true
        trackApplicationStateMessage(ApplicationStateMessage(state: .backgrounded))
    }
    
    func didFinishLaunching(notification: NSNotification) {
        didFinishLaunching = true
                
        if previousVersion == nil {
            trackApplicationStateMessage(ApplicationStateMessage(
                state: .installed,
                properties: getLifeCycleProperties(
                    currentVersion: currentVersion,
                    currentBuild: currentBuild
                )
            ))
        } else if currentVersion != previousVersion {
            trackApplicationStateMessage(ApplicationStateMessage(
                state: .updated,
                properties: getLifeCycleProperties(
                    previousVersion: previousVersion,
                    previousBuild: previousBuild,
                    currentVersion: currentVersion,
                    currentBuild: currentBuild
                )
            ))
        }
        
        userDefaultsWorker.write(.version, value: currentVersion)
        userDefaultsWorker.write(.build, value: currentBuild)
    }
    
    func willEnterForeground(notification: NSNotification) {
        if isBackgrounded {
            refreshSessionIfNeeded()
        }
        
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .opened,
            properties: getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                fromBackground: isBackgrounded
            )
        ))
        isBackgrounded = false
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
            return .willEnterForeground
        default:
            return .unknown
        }
    }
}

extension ApplicationState {
    static func current(
        notificationCenter: NotificationCenter,
        application: NSApplication = NSApplication.shared,
        userDefaultsWorker: UserDefaultsWorkerProtocol,
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
                userDefaultsWorker: userDefaultsWorker
            ),
            notifications: notifications
        )
    }
}

#endif
