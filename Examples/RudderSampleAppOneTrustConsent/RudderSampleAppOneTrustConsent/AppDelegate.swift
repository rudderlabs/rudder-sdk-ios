//
//  AppDelegate.swift
//  RudderSampleAppOneTrustConsent
//
//  Created by Pallab Maiti on 12/01/23.
//

import UIKit
import OTPublishersHeadlessSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let profileSyncParam = OTProfileSyncParams()
        profileSyncParam.setSyncProfile("true")
        profileSyncParam.setSyncProfileAuth("JWT token")
        profileSyncParam.setIdentifier("userId")
        
        let sdkParams = OTSdkParams(countryCode: "US", regionCode: "CA")
        sdkParams.setShouldCreateProfile("true")
//        sdkParams.setBannerHeightRatio(OTBannerHeightRatio.two_third)

        // profileSyncParams explained below
//        sdkParams.setProfileSyncParams(profileSyncParam)
        
        OTPublishersHeadlessSDK.shared.startSDK(
            storageLocation: "cdn.cookielaw.org",
            domainIdentifier: "03b4f096-bd76-48f1-8ea0-ae82b98502a7-test",
            languageCode: "en"
        ) { response in

             print("status: \(response.status)")
             print("result: \(response.responseString ?? "")")
            print("error: \(response.error?.localizedDescription)")

             // Take next action...
             
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

