//
//  RSwatchOSLifecycleEvents.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if os(watchOS)

import Foundation
import WatchKit

class RSwatchOSLifecycleEvents: RSPlatformPlugin, RSwatchOSLifecycle {    
    let type = PluginType.before
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    private var userDefaults: RSUserDefaults?
    private var config: RSConfig?
    
    internal func initialSetup() {
        guard let client = self.client else { return }
        userDefaults = client.userDefaults
        config = client.config
    }
    
    func applicationDidFinishLaunching(watchExtension: WKExtension?) {
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
    
    func applicationWillEnterForeground(watchExtension: WKExtension?) {
        if config?.trackLifecycleEvents == false {
            return
        }
        
        client?.refreshSessionIfNeeded()
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        client?.track("Application Opened", properties: RSUtils.getLifeCycleProperties(
            currentVersion: currentVersion,
            currentBuild: currentBuild,
            fromBackground: true
        ))
    }
}

#endif
