//
//  AppDelegate.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        guard let path = Bundle.main.path(forResource: "RudderConfig", ofType: "plist"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data) else {
            return true
        }
        
        let builder: RSConfigBuilder = RSConfigBuilder()
            .withLoglevel(RSLogLevelDebug)
            .withDataPlaneUrl(rudderConfig.DEV_DATA_PLANE_URL)
            .withControlPlaneUrl(rudderConfig.DEV_CONTROL_PLANE_URL)
            .withTrackLifecycleEvens(false)
            .withRecordScreenViews(false)
            .withSleepTimeOut(4)
            .withSessionTimeoutMillis(30000)
//            .withConsentFilter(CustomFilter())
        RSClient.getInstance(rudderConfig.WRITE_KEY, config: builder.build())
        
        
//        RSClient.sharedInstance()?.track("track_1")
        
//        RSClient.putDeviceToken("device_token")
//        RSClient.sharedInstance()?.getContext().putAdvertisementId("advertising_id")
//        RSClient.sharedInstance()?.getContext().putAppTrackingConsent(RSATTAuthorize)
        
        
//        RSClient.sharedInstance()?.track("track_2")
//        RSClient.sharedInstance()?.track("track_3")
//        RSClient.sharedInstance()?.track("track_4")
        
//        RSClient.sharedInstance()?.track("Track 1")
//        RSClient.sharedInstance()?.identify("user_1")
//        RSClient.sharedInstance()?.track("Track 2")
//        RSClient.sharedInstance()?.alias("alias")
//        RSClient.sharedInstance()?.track("Track 3")

//        RSClient.sharedInstance()?.track("track_1_d")
//        RSClient.sharedInstance()?.track("track_2_d")
//        RSClient.sharedInstance()?.track("track_3_d")
//        RSClient.sharedInstance()?.track("track_4_d")

        
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

