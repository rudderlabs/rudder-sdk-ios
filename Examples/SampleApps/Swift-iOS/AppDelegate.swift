//
//  AppDelegate.swift
//  Swift-iOS
//
//  Created by Pallab Maiti on 11/02/24.
//

import UIKit
import Rudder

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var client1: RSClient!
    var client2: RSClient!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(NSHomeDirectory())
        
        if let path = Bundle.main.path(forResource: "RudderConfig_1", ofType: "plist"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data)
        {
            if let config: Configuration = Configuration(
                writeKey: rudderConfig.WRITE_KEY,
                dataPlaneURL: rudderConfig.DEV_DATA_PLANE_URL
            )?
                .controlPlaneURL(rudderConfig.DEV_CONTROL_PLANE_URL)
                //            .controlPlaneURL("https://e2e6fd4f-c24c-43d6-8ca3-11a11e7cc7d5.mock.pstmn.io") // disabled
                //            .controlPlaneURL("https://98e2b8de-9984-471b-a705-b1bcf3f9f6ba.mock.pstmn.io") // enabled
                .logLevel(.verbose)
                .trackLifecycleEvents(true)
                .recordScreenViews(true)
                .sleepTimeOut(5)
                .gzipEnabled(false)
                .flushQueueSize(0)
            {
                client1 = RSClient.initialize(with: config)
            }
        }
        
        if let path = Bundle.main.path(forResource: "RudderConfig_2", ofType: "plist"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let rudderConfig = try? PropertyListDecoder().decode(RudderConfig.self, from: data)
        {
            if let config: Configuration = Configuration(
                writeKey: rudderConfig.WRITE_KEY,
                dataPlaneURL: rudderConfig.DEV_DATA_PLANE_URL
            )?
                .controlPlaneURL(rudderConfig.DEV_CONTROL_PLANE_URL)
                //            .controlPlaneURL("https://e2e6fd4f-c24c-43d6-8ca3-11a11e7cc7d5.mock.pstmn.io") // disabled
                //            .controlPlaneURL("https://98e2b8de-9984-471b-a705-b1bcf3f9f6ba.mock.pstmn.io") // enabled
                .logLevel(.verbose)
                .trackLifecycleEvents(false)
                .recordScreenViews(false)
                .sleepTimeOut(5)
                .gzipEnabled(false)
                .flushQueueSize(0)
            {
                client2 = RSClient.initialize(with: config, instanceName: "")
            }
        }
        
        
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

