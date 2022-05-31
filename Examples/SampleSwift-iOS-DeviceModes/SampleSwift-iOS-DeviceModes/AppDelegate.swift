//
//  AppDelegate.swift
//  SampleSwift-iOS-DeviceModes
//
//  Created by Pallab Maiti on 31/05/22.
//

import UIKit
import Rudder
import RudderBugsnag
import RudderFirebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let config: RSConfig = RSConfig(writeKey: "1wvsoF3Kx2SczQNlx1dvcqW9ODW")
            .dataPlaneURL("https://rudderstacz.dataplane.rudderstack.com")
            .loglevel(.debug)
            .trackLifecycleEvents(false)
            .recordScreenViews(false)
        
        RSClient.sharedInstance().configure(with: config)
        
        RSClient.sharedInstance().addDestination(RudderFirebaseDestination())
        RSClient.sharedInstance().addDestination(RudderBugsnagDestination())

        
        RSClient.sharedInstance().track("sample_track_1", properties: ["string": "value", "integer": 1, "boolean": true, "double": 1.11])
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


}

