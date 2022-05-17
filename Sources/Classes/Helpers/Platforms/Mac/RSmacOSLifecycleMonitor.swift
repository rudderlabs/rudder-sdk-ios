//
//  macOSLifecycleEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(macOS)
import Cocoa

class RSmacOSLifecycleMonitor: RSPlatformPlugin {
    static var specificName = "Rudder_macOSLifecycleMonitor"
    let type = PluginType.utility
    let name = specificName
    var client: RSClient?
    
    private var application: NSApplication
    private var appNotifications: [NSNotification.Name] =
        [NSApplication.didFinishLaunchingNotification,
         NSApplication.didResignActiveNotification,
         NSApplication.willBecomeActiveNotification,
         NSApplication.didBecomeActiveNotification,
         NSApplication.didHideNotification,
         NSApplication.didUnhideNotification,
         NSApplication.didUpdateNotification,
         NSApplication.willHideNotification,
         NSApplication.willFinishLaunchingNotification,
         NSApplication.willResignActiveNotification,
         NSApplication.willUnhideNotification,
         NSApplication.willUpdateNotification,
         NSApplication.willTerminateNotification,
         NSApplication.didChangeScreenParametersNotification]
    
    required init() {
        self.application = NSApplication.shared        
        setupListeners()
    }
    
    // swiftlint:disable cyclomatic_complexity
    @objc
    func notificationResponse(notification: NSNotification) {
        switch notification.name {
        case NSApplication.didResignActiveNotification:
            self.didResignActive(notification: notification)
        case NSApplication.willBecomeActiveNotification:
            self.applicationWillBecomeActive(notification: notification)
        case NSApplication.didFinishLaunchingNotification:
            self.applicationDidFinishLaunching(notification: notification)
        case NSApplication.didBecomeActiveNotification:
            self.applicationDidBecomeActive(notification: notification)
        case NSApplication.didHideNotification:
            self.applicationDidHide(notification: notification)
        case NSApplication.didUnhideNotification:
            self.applicationDidUnhide(notification: notification)
        case NSApplication.didUpdateNotification:
            self.applicationDidUpdate(notification: notification)
        case NSApplication.willHideNotification:
            self.applicationWillHide(notification: notification)
        case NSApplication.willFinishLaunchingNotification:
            self.applicationWillFinishLaunching(notification: notification)
        case NSApplication.willResignActiveNotification:
            self.applicationWillResignActive(notification: notification)
        case NSApplication.willUnhideNotification:
            self.applicationWillUnhide(notification: notification)
        case NSApplication.willUpdateNotification:
            self.applicationWillUpdate(notification: notification)
        case NSApplication.willTerminateNotification:
            self.applicationWillTerminate(notification: notification)
        case NSApplication.didChangeScreenParametersNotification:
            self.applicationDidChangeScreenParameters(notification: notification)
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
    
    func applicationWillBecomeActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillBecomeActive()
            }
        }
    }
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                let options = notification.userInfo as? [String: Any] ?? nil
                validExt.application(didFinishLaunchingWithOptions: options)
            }
        }
    }
    
    func didResignActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationDidResignActive()
            }
        }
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationDidBecomeActive()
            }
        }
    }
    
    func applicationDidHide(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationDidHide()
            }
        }
    }
    
    func applicationDidUnhide(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationDidUnhide()
            }
        }
    }

    func applicationDidUpdate(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationDidUpdate()
            }
        }
    }
    
    func applicationWillHide(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillHide()
            }
        }
    }
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillFinishLaunching()
            }
        }
    }
    
    func applicationWillResignActive(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillResignActive()
            }
        }
    }
    
    func applicationWillUnhide(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillUnhide()
            }
        }
    }
    
    func applicationWillUpdate(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillUpdate()
            }
        }
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationWillTerminate()
            }
        }
    }
    
    func applicationDidChangeScreenParameters(notification: NSNotification) {
        client?.apply { (ext) in
            if let validExt = ext as? RSmacOSLifecycle {
                validExt.applicationDidChangeScreenParameters()
            }
        }
    }
}

extension RudderDestinationPlugin: RSmacOSLifecycle {
    public func applicationDidBecomeActive() {
        enterForeground()
    }
    
    public func applicationWillResignActive() {
        enterBackground()
    }
}

#endif
