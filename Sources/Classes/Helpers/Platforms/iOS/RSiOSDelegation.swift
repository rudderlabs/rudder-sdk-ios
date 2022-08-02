//
//  iOSDelegation.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
import UserNotifications

extension RSClient {
    @objc
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
            }
        }
    }
    
    @objc
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
            }
        }
    }
    
    @objc
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
            }
        }
    }
    
    @objc
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
            }
        }
    }
    
    @objc
    public func pushAuthorizationFromUserNotificationCenter(_ granted: Bool) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.pushAuthorizationFromUserNotificationCenter(granted)
            }
        }
    }
}

#endif

#if os(tvOS)
import UIKit
import UserNotifications

extension RSClient {
    @objc
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
            }
        }
    }
    
    @objc
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
            }
        }
    }
    
    @objc
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
            }
        }
    }
}

#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

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
