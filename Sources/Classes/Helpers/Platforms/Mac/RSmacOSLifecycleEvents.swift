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
        
        if previousBuild != nil {
            client?.track("Application Installed", properties: [
                "version": currentVersion ?? "",
                "build": currentBuild ?? ""
            ])
        } else if currentBuild != previousBuild {
            client?.track("Application Updated", properties: [
                "previous_version": previousVersion ?? "",
                "previous_build": previousBuild ?? "",
                "version": currentVersion ?? "",
                "build": currentBuild ?? ""
            ])
        }
        
        client?.track("Application Opened", properties: [
            "from_background": false,
            "version": currentVersion ?? "",
            "build": currentBuild ?? ""
        ])
        
        RSUserDefaults.saveApplicationVersion(currentVersion)
        RSUserDefaults.saveApplicationBuild(currentBuild)
    }
    
    func applicationDidUnhide() {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        client?.track("Application Unhidden", properties: [
            "from_background": true,
            "version": currentVersion ?? "",
            "build": currentBuild ?? ""
        ])
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
