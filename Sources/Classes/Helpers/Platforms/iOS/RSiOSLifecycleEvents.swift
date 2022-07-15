//
//  RSiOSLifecycleEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

class RSiOSLifecycleEvents: RSPlatformPlugin, RSiOSLifecycle {
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    var isFirstTimeLaunch: Bool = true    
    @RSAtomic private var didFinishLaunching = false
    private var userDefaults: RSUserDefaults?
    private var config: RSConfig?
    
    internal func initialSetup() {
        guard let client = self.client else { return }
        userDefaults = client.userDefaults
        config = client.config
    }
    
    func application(_ application: UIApplication?, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        didFinishLaunching = true
        
        if config?.trackLifecycleEvents == false {
            return
        }
        
        let previousVersion: String? = userDefaults?.read(.applicationVersion)
        let previousBuild: String? = userDefaults?.read(.applicationBuild)
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if previousVersion == nil {
            client?.track("Application Installed", properties: RSUtils.getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild
            ))
        } else if currentVersion != previousVersion {
            client?.track("Application Updated", properties: RSUtils.getLifeCycleProperties(
                previousVersion: previousVersion,
                previousBuild: previousBuild,
                currentVersion: currentVersion,
                currentBuild: currentBuild
            ))
        }
        
        client?.track("Application Opened", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: false,
            referringApplication: launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication],
            url: launchOptions?[UIApplication.LaunchOptionsKey.url]
        ))
        
        userDefaults?.write(.applicationVersion, value: currentVersion)
        userDefaults?.write(.applicationBuild, value: currentBuild)
    }
    
    func applicationWillEnterForeground(application: UIApplication?) {
        if config?.trackLifecycleEvents == false {
            return
        }
        #if !os(tvOS)
        // If app is launched first time then the Application Opened event will not be sent again.
        if self.isFirstTimeLaunch == true {
            self.isFirstTimeLaunch = false
            return
        }
        #endif
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        client?.track("Application Opened", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: true
        ))
    }
    
    func applicationDidEnterBackground(application: UIApplication?) {
        if config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Backgrounded")
    }
    
    func applicationDidBecomeActive(application: UIApplication?) {
        if config?.trackLifecycleEvents == false {
            return
        }
        
        if didFinishLaunching == false {
            self.application(nil, didFinishLaunchingWithOptions: nil)
        }
    }
}
#endif
