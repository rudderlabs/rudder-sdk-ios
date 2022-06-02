//
//  watchOSLifecycleMonitor.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(watchOS)

import Foundation
import WatchKit

class RSwatchOSLifecycleMonitor: RSPlatformPlugin {
    var type = PluginType.utility
    var client: RSClient?
    var wasBackgrounded: Bool = false
    
    private var watchExtension = WKExtension.shared()
    private var appNotifications: [NSNotification.Name] = [WKExtension.applicationDidFinishLaunchingNotification,
                                                           WKExtension.applicationWillEnterForegroundNotification,
                                                           WKExtension.applicationDidEnterBackgroundNotification,
                                                           WKExtension.applicationDidBecomeActiveNotification,
                                                           WKExtension.applicationWillResignActiveNotification]
    
    required init() {
        watchExtension = WKExtension.shared()
        setupListeners()
    }
    
    @objc
    func notificationResponse(notification: NSNotification) {
        switch notification.name {
        case WKExtension.applicationDidFinishLaunchingNotification:
            self.applicationDidFinishLaunching(notification: notification)
        case WKExtension.applicationWillEnterForegroundNotification:
            self.applicationWillEnterForeground(notification: notification)
        case WKExtension.applicationDidEnterBackgroundNotification:
            self.applicationDidEnterBackground(notification: notification)
        case WKExtension.applicationDidBecomeActiveNotification:
            self.applicationDidBecomeActive(notification: notification)
        case WKExtension.applicationWillResignActiveNotification:
            self.applicationWillResignActive(notification: notification)
        default:
            break
        }
    }
    
    func setupListeners() {
        // Configure the current life cycle events
        let notificationCenter = NotificationCenter.default
        for notification in appNotifications {
            notificationCenter.addObserver(self, selector: #selector(notificationResponse(notification:)), name: notification, object: nil)
        }
    }
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSwatchOSLifecycle {
                validExt.applicationDidFinishLaunching(watchExtension: watchExtension)
            }
        }
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        // watchOS will receive this after didFinishLaunching, which is different
        // from iOS, so ignore until we've been backgrounded at least once.
        if wasBackgrounded == false { return }
        
        client?.apply { (ext) in
            if let validExt = ext as? RSwatchOSLifecycle {
                validExt.applicationWillEnterForeground(watchExtension: watchExtension)
            }
        }
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        // make sure to denote that we were backgrounded.
        wasBackgrounded = true
        
        client?.apply { (ext) in
            if let validExt = ext as? RSwatchOSLifecycle {
                validExt.applicationDidEnterBackground(watchExtension: watchExtension)
            }
        }
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSwatchOSLifecycle {
                validExt.applicationDidBecomeActive(watchExtension: watchExtension)
            }
        }
    }
    
    func applicationWillResignActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSwatchOSLifecycle {
                validExt.applicationWillResignActive(watchExtension: watchExtension)
            }
        }
    }
    
}

// MARK: - RudderStack Destination Extension

extension RudderDestinationPlugin: RSwatchOSLifecycle {
    public func applicationWillEnterForeground(watchExtension: WKExtension?) {
        enterForeground()
    }
    
    public func applicationDidEnterBackground(watchExtension: WKExtension?) {
        enterBackground()
    }
}

#endif
