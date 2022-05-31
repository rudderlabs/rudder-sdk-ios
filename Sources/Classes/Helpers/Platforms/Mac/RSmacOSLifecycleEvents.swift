//
//  RSmacOSLifecycleEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 01/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(macOS)
import Foundation

class RSmacOSLifecycleEvents: RSPlatformPlugin, RSmacOSLifecycle {
    let type = PluginType.before
    var client: RSClient?

    @RSAtomic private var didFinishLaunching = false
    
    func application(didFinishLaunchingWithOptions launchOptions: [String: Any]?) {
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
            fromBackground: false
        ))
        
        RSUserDefaults.saveApplicationVersion(currentVersion)
        RSUserDefaults.saveApplicationBuild(currentBuild)
    }
    
    func applicationDidUnhide() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        client?.track("Application Unhidden", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: true
        ))
    }
    
    func applicationDidHide() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Hidden")
    }
    func applicationDidResignActive() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Backgrounded")
    }
    
    func applicationDidBecomeActive() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        if didFinishLaunching == false {
            application(didFinishLaunchingWithOptions: nil)
        }
    }
    
    func applicationWillTerminate() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Terminated")
    }
}
#endif
