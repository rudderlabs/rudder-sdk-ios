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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// Create a `Configuration.json` file on root directory. The JSON should be look like:
        /// {
        ///    "WRITE_KEY": "WRITE_KEY_VALUE",
        ///    "DATA_PLANE_URL_LOCAL": "DATA_PLANE_URL_LOCAL_VALUE",
        ///    "DATA_PLANE_URL_PROD": "DATA_PLANE_URL_PROD_VALUE",
        ///    "CONTROL_PLANE_URL": "CONTROL_PLANE_URL_VALUE"
        /// }
        
        let filePath = URL(fileURLWithPath: #file).pathComponents.dropLast().dropLast().dropLast().dropLast().joined(separator: "/").replacingOccurrences(of: "//", with: "/") + "/Configuration.json"
        do {
            let jsonString = try String(contentsOfFile: filePath, encoding: .utf8)
            let jsonData = Data(jsonString.utf8)
            let configuration = try JSONDecoder().decode(Configuration.self, from: jsonData)
            
            let config: RSConfig = RSConfig(writeKey: configuration.WRITE_KEY)
                .dataPlaneURL(configuration.DATA_PLANE_URL_PROD)
                .controlPlaneURL(configuration.CONTROL_PLANE_URL)
                .loglevel(.verbose)
                .trackLifecycleEvents(false)
                .recordScreenViews(true)
                .flushQueueSize(8)
//                .sleepTimeOut(1)
            RSClient.sharedInstance().configure(with: config)
            RSClient.sharedInstance().addDestination(CustomDestination())
            
            /*let option = RSOption()
                        option.putExternalId("key-1", withId: "value-1")
                        option.putExternalId("key-2", withId: "value-2")
                        option.putExternalId("key-3", withId: "value-3")
                        option.putExternalId("key-4", withId: "value-4")

                        option.putIntegration("key-5", isEnabled: true)
                        option.putIntegration("key-6", isEnabled: true)
                        option.putIntegration("key-7", isEnabled: true)
                        option.putIntegration("key-8", isEnabled: false)

                        option.putCustomContext(["Key-01": "value-1"], withKey: "key-9")
                        option.putCustomContext(["Key-02": "value-1"], withKey: "key-10")
                        option.putCustomContext(["Key-03": "value-1"], withKey: "key-11")
                        option.putCustomContext(["Key-04": "value-1"], withKey: "key-12")
            
            RSClient.sharedInstance().setOption(option)
            RSClient.sharedInstance().setAdvertisingId("advertising_id")
            RSClient.sharedInstance().identify("user_id_1")
            RSClient.sharedInstance().track("track events_1")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                RSClient.sharedInstance().reset()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                RSClient.sharedInstance().track("track events_2")
            }
            

            RSClient.sharedInstance().track("sample_track_1")
            RSClient.sharedInstance().setDeviceToken("device_token_1")
            RSClient.sharedInstance().identify("user_id_1", traits: ["name": "Pallab", "email": "pallab@pallab.com", "age": 79])
            RSClient.sharedInstance().setDeviceToken("device_token_2")
            RSClient.sharedInstance().track("sample_track_2")
            RSClient.sharedInstance().setDeviceToken("device_token_3")
            RSClient.sharedInstance().alias("user_id_2")
            RSClient.sharedInstance().setAdvertisingId("advertising_id")
            RSClient.sharedInstance().setAppTrackingConsent(.authorize)
            RSClient.sharedInstance().configure(with: config)
            RSClient.sharedInstance().track("sample_track_3")
            RSClient.sharedInstance().addDestination(CustomDestination())
            
            RSClient.sharedInstance().setAppTrackingConsent(.authorize)
            RSClient.sharedInstance().setAnonymousId("example_anonymous_id")
            RSClient.sharedInstance().setAdvertisingId(getIDFA())
            RSClient.sharedInstance().setDeviceToken("example_device_token")
            
            RSClient.sharedInstance().setOptOutStatus(true)
            RSClient.sharedInstance().reset()
            
            let traits = RSClient.sharedInstance().traits
            let defaultOption = RSOption()
            defaultOption.putIntegration("Amplitude", isEnabled: true)
            RSClient.sharedInstance().setOption(defaultOption)
            
            let messageOption = RSOption()
            messageOption.putIntegration("MoEngage", isEnabled: true)
            messageOption.putExternalId("", withId: "")
            RSClient.sharedInstance().identify("Track 2", traits: ["email": "abc@def.com"], option: messageOption)*/
        } catch { }
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

struct Configuration: Codable {
    let WRITE_KEY: String
    let DATA_PLANE_URL_LOCAL: String
    let DATA_PLANE_URL_PROD: String
    let CONTROL_PLANE_URL: String
}
