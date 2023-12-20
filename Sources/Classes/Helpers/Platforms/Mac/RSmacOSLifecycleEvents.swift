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
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }

    @RSAtomic private var didFinishLaunching = false
    @RSAtomic private var fromBackground = false
    private var userDefaults: RSUserDefaults?
    private var config: RSConfig?
    
    internal func initialSetup() {
        guard let client = self.client else { return }
        userDefaults = client.userDefaults
        config = client.config
    }
    
    func application(didFinishLaunchingWithOptions launchOptions: [String: Any]?) {
        didFinishLaunching = true
        
        if config?.trackLifecycleEvents == false {
            return
        }
        
        let previousVersion: String? = userDefaults?.read(application: .version)
        let previousBuild: String? = userDefaults?.read(application: .build)
        
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
        
        userDefaults?.write(application: .version, value: currentVersion)
        userDefaults?.write(application: .build, value: currentBuild)
    }
    
    func applicationDidBecomeActive() {
        if config?.trackLifecycleEvents == false {
            return
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        if didFinishLaunching == false {
            didFinishLaunching = true
            
            let previousVersion: String? = userDefaults?.read(application: .version)
            let previousBuild: String? = userDefaults?.read(application: .build)
                        
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
            
            userDefaults?.write(application: .version, value: currentVersion)
            userDefaults?.write(application: .build, value: currentBuild)
        }
        
        if fromBackground {
            client?.refreshSessionIfNeeded()
        }
        
        client?.track("Application Opened", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: fromBackground
        ))
        
    }
    
    func applicationDidResignActive() {
        fromBackground = true

        if client?.config.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Backgrounded")
    }
    
    func applicationWillTerminate() {
        if config?.trackLifecycleEvents == false {
            return
        }
        
        client?.track("Application Terminated")
    }
}
#endif
