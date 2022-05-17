//
//  LifecycleEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Foundation
import UIKit

class RSiOSLifecycleMonitor: RSPlatformPlugin {
    let type = PluginType.utility
    var client: RSClient?
    
    private var application: UIApplication = UIApplication.shared
    private var appNotifications: [NSNotification.Name] = [UIApplication.didEnterBackgroundNotification,
                                                           UIApplication.willEnterForegroundNotification,
                                                           UIApplication.didFinishLaunchingNotification,
                                                           UIApplication.didBecomeActiveNotification,
                                                           UIApplication.willResignActiveNotification,
                                                           UIApplication.didReceiveMemoryWarningNotification,
                                                           UIApplication.willTerminateNotification,
                                                           UIApplication.significantTimeChangeNotification,
                                                           UIApplication.backgroundRefreshStatusDidChangeNotification]

    required init() {
        setupListeners()
    }
    
    @objc
    func notificationResponse(notification: NSNotification) {        
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            self.didEnterBackground(notification: notification)
        case UIApplication.willEnterForegroundNotification:
            self.applicationWillEnterForeground(notification: notification)
        case UIApplication.didFinishLaunchingNotification:
            self.didFinishLaunching(notification: notification)
        case UIApplication.didBecomeActiveNotification:
            self.didBecomeActive(notification: notification)
        case UIApplication.willResignActiveNotification:
            self.willResignActive(notification: notification)
        case UIApplication.didReceiveMemoryWarningNotification:
            self.didReceiveMemoryWarning(notification: notification)
        case UIApplication.significantTimeChangeNotification:
            self.significantTimeChange(notification: notification)
        case UIApplication.backgroundRefreshStatusDidChangeNotification:
            self.backgroundRefreshDidChange(notification: notification)
        default:
            
            break
        }
    }
    
    func setupListeners() {
        // Configure the current life cycle events
        let notificationCenter = NotificationCenter.default
        for notification in appNotifications {
            notificationCenter.addObserver(self, selector: #selector(notificationResponse(notification:)), name: notification, object: application)
        }

    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationWillEnterForeground(application: application)
            }
        }
    }
    
    func didEnterBackground(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationDidEnterBackground(application: application)
            }
        }
    }
    
    func didFinishLaunching(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                let options = notification.userInfo as? [UIApplication.LaunchOptionsKey: Any] ?? nil
                validExt.application(application, didFinishLaunchingWithOptions: options)
            }
        }
    }

    func didBecomeActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationDidBecomeActive(application: application)
            }
        }
    }
    
    func willResignActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationWillResignActive(application: application)
            }
        }
    }
    
    func didReceiveMemoryWarning(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationDidReceiveMemoryWarning(application: application)
            }
        }
    }
    
    func willTerminate(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationWillTerminate(application: application)
            }
        }
    }
    
    func significantTimeChange(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationSignificantTimeChange(application: application)
            }
        }
    }
    
    func backgroundRefreshDidChange(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSiOSLifecycle {
                validExt.applicationBackgroundRefreshDidChange(application: application,
                                                               refreshStatus: application.backgroundRefreshStatus)
            }
        }
    }
}

// MARK: - RudderStack Destination Extension

extension RudderDestinationPlugin: RSiOSLifecycle {
    func applicationWillEnterForeground(application: UIApplication?) {
        enterForeground()
    }
    
    func applicationDidEnterBackground(application: UIApplication?) {
        enterBackground()
    }
}

#endif
