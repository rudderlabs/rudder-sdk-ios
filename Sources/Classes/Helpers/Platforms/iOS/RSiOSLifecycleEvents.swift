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
    var client: RSClient?
    var isFirstTimeLaunch: Bool = true
    
    @RSAtomic private var didFinishLaunching = false
    
    func application(_ application: UIApplication?, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        didFinishLaunching = true
        
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        let previousVersion = RSUserDefaults.getApplicationVersion()
        let previousBuild = RSUserDefaults.getApplicationBuild()
        
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
        
        RSUserDefaults.saveApplicationVersion(currentVersion)
        RSUserDefaults.saveApplicationBuild(currentBuild)
    }
    
    func applicationWillEnterForeground(application: UIApplication?) {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        #if !os(tvOS)
        // If app is launched first time then the Application Opened event will not be sent again.
        if self.isFirstTimeLaunch == true {
            self.isFirstTimeLaunch = false
            return
        }
        #endif
        
        RSUserSessionPlugin.sharedInstance()?.refreshSessionWhenAppEntersForeground()
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        client?.track("Application Opened", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: true
        ))
    }
    
    func applicationDidEnterBackground(application: UIApplication?) {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Backgrounded")
    }
    
    func applicationDidBecomeActive(application: UIApplication?) {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        if didFinishLaunching == false {
            self.application(nil, didFinishLaunchingWithOptions: nil)
        }
    }
}
#endif
