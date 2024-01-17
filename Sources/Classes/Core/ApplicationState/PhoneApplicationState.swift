//
//  PhoneApplicationState.swift
//  Rudder
//
//  Created by Pallab Maiti on 29/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

class PhoneApplicationState: ApplicationStateProtocol {
    let application: UIApplication
    let userDefaults: UserDefaultsWorkerType
    
    var trackApplicationStateMessage: ((ApplicationStateMessage) -> Void) = { _  in }
    var refreshSessionIfNeeded: (() -> Void) = { }
    
    @ReadWriteLock private var isFirstTimeLaunch: Bool = true
    @ReadWriteLock private var didFinishLaunching = false

    init(application: UIApplication, userDefaults: UserDefaultsWorkerType) {
        self.application = application
        self.userDefaults = userDefaults
    }
    
    func didEnterBackground(notification: NSNotification) {
        trackApplicationStateMessage(ApplicationStateMessage(state: .backgrounded))
    }
    
    func willEnterForeground(notification: NSNotification) {
        #if !os(tvOS)
        // If app is launched first time then the Application Opened event will not be sent again.
        if self.isFirstTimeLaunch {
            self.isFirstTimeLaunch = false
            return
        }
        #endif
        refreshSessionIfNeeded()
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .opened,
            properties: Utility.getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                fromBackground: true
            )
        ))
    }
    
    func didFinishLaunching(notification: NSNotification) {
        didFinishLaunching = true
        
        let previousVersion: String? = userDefaults.read(.version)
        let previousBuild: String? = userDefaults.read(.build)
        
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
        if !didFinishLaunching {
            didFinishLaunching(notification: notification)
        }
    }
}

extension Notification.Name {
    func convert() -> NotificationName {
        switch self {
        case UIApplication.didEnterBackgroundNotification:
            return .didEnterBackground
        case UIApplication.willEnterForegroundNotification:
            return .willEnterForeground
        case UIApplication.didFinishLaunchingNotification:
            return .didFinishLaunching
        case UIApplication.didBecomeActiveNotification:
            return .didBecomeActive
        default:
            return .unknown
        }
    }
}

extension ApplicationState {
    static func current(
        notificationCenter: NotificationCenter,
        application: UIApplication = UIApplication.shared,
        userDefaults: UserDefaultsWorkerType,
        notifications: [Notification.Name] = [
            UIApplication.didEnterBackgroundNotification,
            UIApplication.willEnterForegroundNotification,
            UIApplication.didFinishLaunchingNotification,
            UIApplication.didBecomeActiveNotification
        ]
    ) -> Self {
        self.init(
            notificationCenter: notificationCenter,
            application: PhoneApplicationState(
                application: application,
                userDefaults: userDefaults
            ),
            notifications: notifications
        )
    }
}

#endif
