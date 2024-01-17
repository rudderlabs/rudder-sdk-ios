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
import Network
import RudderFirebase
import RudderAmplitude

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard let path = Bundle.main.path(forResource: "RudderConfig", ofType: "plist"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data) else {
            return true
        }
        
        print(NSHomeDirectory())
        
        let config: RSConfig = RSConfig(writeKey: rudderConfig.WRITE_KEY, dataPlaneURL: rudderConfig.DEV_DATA_PLANE_URL)
            .controlPlaneURL(rudderConfig.DEV_CONTROL_PLANE_URL)
//            .dataResidencyServer(.EU)
//            .controlPlaneURL("https://e2e6fd4f-c24c-43d6-8ca3-11a11e7cc7d5.mock.pstmn.io") // disabled
//            .controlPlaneURL("https://98e2b8de-9984-471b-a705-b1bcf3f9f6ba.mock.pstmn.io") // enabled
            .loglevel(.verbose)
            .trackLifecycleEvents(true)
            .recordScreenViews(true)
            .sleepTimeOut(20)
            .gzipEnabled(false)
        
        RSClient.sharedInstance().configure(with: config)
        
        
        RSClient.sharedInstance().addDestination(RudderAmplitudeDestination())
        RSClient.sharedInstance().addDestination(RudderFirebaseDestination())
            
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
