//
//  PushNotifications.swift
//  Rudder
//
//  Created by Pallab Maiti on 03/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

#if os(iOS) || targetEnvironment(macCatalyst)

import UIKit
import UserNotifications

public protocol PushNotifications: Plugin {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    func pushAuthorizationFromUserNotificationCenter(_ granted: Bool)
}

public extension PushNotifications {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {}
    func pushAuthorizationFromUserNotificationCenter(_ granted: Bool) {}
}
#endif

#if os(tvOS)

import UIKit
import UserNotifications

public protocol PushNotifications: Plugin {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

public extension PushNotifications {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
}
#endif

#if os(watchOS)

import Foundation
import WatchKit
import UserNotifications

public protocol PushNotifications: Plugin {
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error)
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
}

public extension PushNotifications {
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {}
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {}
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {}
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {}
}
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
import UserNotifications

extension RSClient {
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
            }
        }
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
            }
        }
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
            }
        }
    }
    
    public func pushAuthorizationFromUserNotificationCenter(_ granted: Bool) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
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
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
            }
        }
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
            }
        }
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
            }
        }
    }
}

#endif

#if os(watchOS)

import Foundation
import WatchKit
import UserNotifications

extension RSClient {
    public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
            }
        }
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.didFailToRegisterForRemoteNotificationsWithError(error)
            }
        }
    }
    
    public func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        associatePlugins { plugin in
            if let p = plugin as? PushNotifications {
                p.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
            }
        }
    }
}

#endif
