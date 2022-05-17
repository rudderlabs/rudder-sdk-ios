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

}

#endif
