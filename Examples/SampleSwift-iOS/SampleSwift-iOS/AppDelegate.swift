//
//  AppDelegate.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var client: RSClient!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config: RSConfig = RSConfig(writeKey: "1wvsoF3Kx2SczQNlx1dvcqW9ODW")
            .dataPlaneURL("https://rudderstacz.dataplane.rudderstack.com")
            .loglevel(.none)
            .trackLifecycleEvents(true)
            .recordScreenViews(false)
        
        client = RSClient.sharedInstance()
        client.configure(with: config)
                
        /*client?.addDestination(CustomDestination())
        
        client?.setAppTrackingConsent(.authorize)
        client?.setAnonymousId("example_anonymous_id")
        client?.setAdvertisingId(getIDFA())
        client?.setDeviceToken("example_device_token")*/
        
        /*client?.setOptOutStatus(true)
        client?.reset()
                
        let traits = client?.traits
        let defaultOption = RSOption()
        defaultOption.putIntegration("Amplitude", isEnabled: true)
        client?.setOption(defaultOption)
        
        let messageOption = RSOption()
        messageOption.putIntegration("MoEngage", isEnabled: true)
        messageOption.putExternalId("", withId: "")
        client?.identify("Track 2", traits: ["email": "abc@def.com"], option: messageOption)*/
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func getIDFA() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}

extension UIApplicationDelegate {
    var client: RSClient? {
        if let appDelegate = self as? AppDelegate {
            return appDelegate.client
        }
        return nil
    }
}
