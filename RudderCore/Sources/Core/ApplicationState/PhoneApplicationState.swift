//
//  PhoneApplicationState.swift
//  Rudder
//
//  Created by Pallab Maiti on 29/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

class PhoneApplicationState: ApplicationStateProtocol {
    let application: UIApplication
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
    
    @ReadWriteLock private var isBackgrounded = false

    init(application: UIApplication, userDefaultsWorker: UserDefaultsWorkerProtocol, bundle: Bundle = Bundle.main) {
        self.application = application
        self.userDefaultsWorker = userDefaultsWorker
        self.bundle = bundle
    }
    
    func didEnterBackground(notification: NSNotification) {
        isBackgrounded = true
        trackApplicationStateMessage(ApplicationStateMessage(state: .backgrounded))
    }
    
    func willEnterForeground(notification: NSNotification) {
        refreshSessionIfNeeded()
        
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
    
    func didFinishLaunching(notification: NSNotification) {
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
        default:
            return .unknown
        }
    }
}

extension ApplicationState {
    static func current(
        notificationCenter: NotificationCenter,
        application: UIApplication = UIApplication.shared,
        userDefaultsWorker: UserDefaultsWorkerProtocol,
        notifications: [Notification.Name] = [
            UIApplication.didEnterBackgroundNotification,
            UIApplication.willEnterForegroundNotification,
            UIApplication.didFinishLaunchingNotification
        ]
    ) -> Self {
        self.init(
            notificationCenter: notificationCenter,
            application: PhoneApplicationState(
                application: application,
                userDefaultsWorker: userDefaultsWorker
            ),
            notifications: notifications
        )
    }
}

#endif
