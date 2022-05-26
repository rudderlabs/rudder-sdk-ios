//
//  RSwatchOSDelegation.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(watchOS)

import Foundation
import WatchKit
import UserNotifications

extension RSClient {
    @objc
    public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        setDeviceToken(deviceToken.hexString)
        
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
            }
        }
    }
    
    @objc
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.didFailToRegisterForRemoteNotificationsWithError(error)
            }
        }
    }
    
    @objc
    public func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        apply { plugin in
            if let p = plugin as? RSPushNotifications {
                p.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
            }
        }
    }
}

#endif
