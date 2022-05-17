//
//  iOSDelegation.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit

extension RSClient {
    @objc
    public func registeredForRemoteNotifications(deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.registeredForRemoteNotifications(deviceToken: deviceToken)
            }
        }
    }
    
    @objc
    public func failedToRegisterForRemoteNotification(error: Error?) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.failedToRegisterForRemoteNotification(error: error)
            }
        }
    }
    
    @objc
    public func receivedRemoteNotification(userInfo: [AnyHashable: Any]) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.receivedRemoteNotification(userInfo: userInfo)
            }
        }
    }
    
    @objc
    public func handleAction(identifier: String, userInfo: [String: Any]) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.handleAction(identifier: identifier, userInfo: userInfo)
            }
        }
    }
}

// MARK: - User Activity

protocol UserActivities {
    func continueUserActivity(_ activity: NSUserActivity)
}

extension UserActivities {
    func continueUserActivity(_ activity: NSUserActivity) {}
}

extension RSClient {
    @objc
    public func continueUserActivity(_ activity: NSUserActivity) {
        apply { plugin in
            if let p = plugin as? UserActivities {
                p.continueUserActivity(activity)
            }
        }
    }
}

// MARK: - Opening a URL

protocol OpeningURLs {
    func openURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any])
}

extension OpeningURLs {
    func openURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {}
}

extension RSClient {
    @objc
    public func openURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) {
        apply { plugin in
            if let p = plugin as? OpeningURLs {
                p.openURL(url, options: options)
            }
        }
    }
}

#endif
