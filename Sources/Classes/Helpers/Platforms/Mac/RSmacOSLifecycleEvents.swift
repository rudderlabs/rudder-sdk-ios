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
    @RSAtomic private var fromBackground = false

    func applicationDidBecomeActive() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        if didFinishLaunching == false {
            didFinishLaunching = true
            
            let previousVersion = RSUserDefaults.getApplicationVersion()
            let previousBuild = RSUserDefaults.getApplicationBuild()
                        
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
            
            RSUserDefaults.saveApplicationVersion(currentVersion)
            RSUserDefaults.saveApplicationBuild(currentBuild)
        }
        
        if fromBackground {
            RSUserSessionPlugin.sharedInstance()?.refreshSessionWhenAppEntersForeground()
        }
        
        client?.track("Application Opened", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: fromBackground
        ))
        
    }
    
    func applicationDidResignActive() {
        fromBackground = true

        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Backgrounded")
    }
    
    func applicationWillTerminate() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Terminated")
    }
}
#endif
