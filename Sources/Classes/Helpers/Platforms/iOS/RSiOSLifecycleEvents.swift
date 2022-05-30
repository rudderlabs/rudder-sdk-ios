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
            client?.track("Application Installed", properties: getApplicationInstalledProps(
                currentVersion: currentVersion,
                currentBuild: currentBuild
            ))
        } else if currentVersion != previousVersion {
            client?.track("Application Updated", properties: getApplicationUpdatedProps(
                previousVersion: previousVersion,
                previousBuild: previousBuild,
                currentVersion: currentVersion,
                currentBuild: currentBuild
            ))
        }
        
        client?.track("Application Opened", properties: getApplicationOpenedProps(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            referring_application: launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication],
            url: launchOptions?[UIApplication.LaunchOptionsKey.url]
        ))
        
        RSUserDefaults.saveApplicationVersion(currentVersion)
        RSUserDefaults.saveApplicationBuild(currentBuild)
    }
    
    func applicationWillEnterForeground(application: UIApplication?) {
        if client?.config?.trackLifecycleEvents == false {
            return
        }
        
        // If app is launched first time then the Application Opened event will not be sent again.
        if self.isFirstTimeLaunch == true {
            self.isFirstTimeLaunch = false
            return
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        client?.track("Application Opened", properties: getApplicationOpenedProps(
            currentVersion: currentVersion,
            currentBuild: currentBuild
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

extension RSiOSLifecycleEvents {
    func getApplicationUpdatedProps(previousVersion: String?, previousBuild: String?, currentVersion: String?, currentBuild: String?) -> [String: Any] {
        var properties = [String: Any]()
        if let previousVersion = previousVersion, !previousVersion.isEmpty {
            properties["previous_version"] = previousVersion
        }
        if let previousBuild = previousBuild, !previousBuild.isEmpty {
            properties["previous_build"] = previousBuild
        }
        if let currentVersion = currentVersion, !currentVersion.isEmpty {
            properties["version"] = currentVersion
        }
        if let currentBuild = currentBuild, !currentBuild.isEmpty {
            properties["build"] = currentBuild
        }
        return properties
    }
    
    func getApplicationInstalledProps(currentVersion: String?, currentBuild: String?) -> [String: Any]{
        var properties = [String: Any]()
        if let currentVersion = currentVersion, !currentVersion.isEmpty {
            properties["version"] = currentVersion
        }
        if let currentBuild = currentBuild, !currentBuild.isEmpty {
            properties["build"] = currentBuild
        }
        return properties
    }
    
    func getApplicationOpenedProps(currentVersion: String?, currentBuild: String?, referring_application: Any?, url: Any?) -> [String: Any] {
        var properties = [String: Any]()
        properties["from_background"] = false
        if let currentVersion = currentVersion, !currentVersion.isEmpty {
            properties["version"] = currentVersion
        }
        if let currentBuild = currentBuild, !currentBuild.isEmpty {
            properties["build"] = currentBuild
        }
        if let referring_application = referring_application {
            properties["referring_application"] = referring_application
        }
        if let url = url {
            properties["url"] = url
        }
        return properties
    }
    
    func getApplicationOpenedProps(currentVersion: String?, currentBuild: String?) -> [String: Any] {
        var properties = [String: Any]()
        properties["from_background"] = true
        if let currentVersion = currentVersion, !currentVersion.isEmpty {
            properties["version"] = currentVersion
        }
        if let currentBuild = currentBuild, !currentBuild.isEmpty {
            properties["build"] = currentBuild
        }
        return properties
    }
}

#endif
