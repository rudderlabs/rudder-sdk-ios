//
//  RSCustomDestination.swift
//  SampleSwift-iOS
//
//  Created by Pallab Maiti on 25/05/22.
//  Copyright © 2022 RudderStack. All rights reserved.
//

import Foundation
import Rudder
import UIKit

class RSCustomDestination: RSDestinationPlugin {
    var key: String = "Custom"
    var controller = RSController()
    var type: PluginType = .destination
    var client: RSClient?
    
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        // Do something
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        // Do something
        return message
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        // Do something
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        // Do something
        return message
    }
    
    func group(message: GroupMessage) -> GroupMessage? {
        // Do something
        return message
    }
    
    func alias(message: AliasMessage) -> AliasMessage? {
        // Do something
        return message
    }
    
    func flush() {
        // Do something
    }
    
    func reset() {
        // Do something
    }
}

extension RSCustomDestination: RSPushNotifications {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
}

class CustomDestination: RudderDestination {
    override init() {
        super.init()
        plugin = RSCustomDestination()
    }
}
