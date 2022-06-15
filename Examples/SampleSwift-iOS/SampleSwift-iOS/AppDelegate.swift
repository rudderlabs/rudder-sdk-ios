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
        ///    "DATA_PLANE_URL": "DATA_PLANE_URL_VALUE",
        ///    "CONTROL_PLANE_URL": "CONTROL_PLANE_URL_VALUE"
        /// }
        
        let filePath = URL(fileURLWithPath: #file).pathComponents.dropLast().dropLast().dropLast().dropLast().joined(separator: "/").replacingOccurrences(of: "//", with: "/") + "/Configuration.json"
        do {
            let jsonString = try String(contentsOfFile: filePath, encoding: .utf8)
            let jsonData = Data(jsonString.utf8)
            let configuration = try JSONDecoder().decode(Configuration.self, from: jsonData)
            
            let config: RSConfig = RSConfig(writeKey: configuration.WRITE_KEY)
                .dataPlaneURL(configuration.DATA_PLANE_URL)
                .loglevel(.verbose)
                .trackLifecycleEvents(true)
                .recordScreenViews(false)
            
            RSClient.sharedInstance().configure(with: config)
        
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
    let DATA_PLANE_URL: String
    let CONTROL_PLANE_URL: String
    let WRITE_KEY: String
}
