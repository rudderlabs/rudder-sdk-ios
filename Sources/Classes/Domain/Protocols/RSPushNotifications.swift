//
//  RSPushNotifications.swift
//  RudderStack
//
//  Created by Pallab Maiti on 03/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

public protocol RSPushNotifications: RSPlugin {
    func registeredForRemoteNotifications(deviceToken: Data)
    func failedToRegisterForRemoteNotification(error: Error?)
    func receivedRemoteNotification(userInfo: [AnyHashable: Any])
    func handleAction(identifier: String, userInfo: [String: Any])
}

public extension RSPushNotifications {
    func registeredForRemoteNotifications(deviceToken: Data) {}
    func failedToRegisterForRemoteNotification(error: Error?) {}
    func receivedRemoteNotification(userInfo: [AnyHashable: Any]) {}
    func handleAction(identifier: String, userInfo: [String: Any]) {}
}
#endif

#if os(watchOS)

import Foundation
import WatchKit

public protocol RSPushNotifications: RSPlugin {
    func registeredForRemoteNotifications(deviceToken: Data)
    func failedToRegisterForRemoteNotification(error: Error?)
    func receivedRemoteNotification(userInfo: [AnyHashable: Any])
}

public extension RSPushNotifications {
    func registeredForRemoteNotifications(deviceToken: Data) {}
    func failedToRegisterForRemoteNotification(error: Error?) {}
    func receivedRemoteNotification(userInfo: [AnyHashable: Any]) {}
}
#endif
