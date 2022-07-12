//
//  RSClient+Plugins.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension RSClient {
        
    internal func addPlugins() {
        add(plugin: RSReplayQueuePlugin())
        
        let logPlugin = RSLoggerPlugin()
        logPlugin.loggingEnabled(config?.logLevel != RSLogLevel.none)
        add(plugin: logPlugin)
        
        add(plugin: RSIntegrationPlugin())
        add(plugin: RudderDestinationPlugin())
        add(plugin: RSGDPRPlugin())
        
        if let platformPlugins = platformPlugins() {
            for plugin in platformPlugins {
                add(plugin: plugin)
            }
        }
        
        setupServerConfigCheck()
    }
    
    internal func platformPlugins() -> [RSPlatformPlugin]? {
        var plugins = [RSPlatformPlugin]()
        
        plugins.append(RSContextPlugin())
        
        plugins.append(RSIdentifyTraitsPlugin())
        plugins.append(RSAliasIdPlugin())
        plugins.append(RSUserIdPlugin())
        plugins.append(RSAnonymousIdPlugin())
        plugins.append(RSAppTrackingConsentPlugin())
        plugins.append(RSAdvertisingIdPlugin())
        
        plugins += Vendor.current.requiredPlugins

        if config?.trackLifecycleEvents == true {
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            plugins.append(RSiOSLifecycleEvents())
            #endif
            #if os(watchOS)
            plugins.append(RSwatchOSLifecycleEvents())
            #endif
            #if os(macOS)
            plugins.append(RSmacOSLifecycleEvents())
            #endif
        }
        
        if config?.recordScreenViews == true {
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            plugins.append(RSiOSScreenViewEvents())
            #endif
            #if os(watchOS)
            plugins.append(RSwatchOSScreenViewEvents())
            #endif
            #if os(macOS)
            plugins.append(RSmacOSScreenViewEvents())
            #endif
        }
        
        if plugins.isEmpty {
            return nil
        } else {
            return plugins
        }
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit
extension RSClient {
    internal func setupServerConfigCheck() {
        checkServerConfig()
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] (notification) in
            guard let self = self, let app = notification.object as? UIApplication else { return }
            if app.applicationState == .background {
                self.checkServerConfig()
            }
        }
    }
}
#elseif os(watchOS)
extension RSClient {
    internal func setupServerConfigCheck() {
        checkServerConfig()
    }
}
#elseif os(macOS)
import Cocoa
extension RSClient {
    internal func setupServerConfigCheck() {
        checkServerConfig()
        RSRepeatingTimer.schedule(interval: .days(1), queue: .main) { [weak self] in
            guard let self = self else { return }
            self.checkServerConfig()
        }
    }
}
#endif

extension RSClient {
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        apply { (plugin) in
            update(plugin: plugin, serverConfig: serverConfig, type: type)
        }
    }
    
    func update(plugin: RSPlugin, serverConfig: RSServerConfig, type: UpdateType) {
        plugin.update(serverConfig: serverConfig, type: type)
        if let dest = plugin as? RSDestinationPlugin {
            dest.apply { (subPlugin) in
                subPlugin.update(serverConfig: serverConfig, type: type)
            }
        }
    }
    
    func checkServerConfig() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var retryCount = 0
            var isCompleted = false
            while !isCompleted && retryCount < 4 {
                if let serverConfig = self.fetchServerConfig() {
                    self.serverConfig = serverConfig
                    RSUserDefaults.saveServerConfig(serverConfig)
                    RSUserDefaults.updateLastUpdatedTime(RSUtils.getTimeStamp())
                    self.log(message: "server config download successful", logLevel: .debug)
                    isCompleted = true
                } else {
                    if self.error?.code == RSErrorCode.WRONG_WRITE_KEY.rawValue {
                        self.log(message: "Wrong write key", logLevel: .debug)
                        retryCount = 4
                    } else {
                        self.log(message: "Retrying download in \(retryCount) seconds", logLevel: .debug)
                        retryCount += 1
                        sleep(UInt32(retryCount))
                    }
                }
            }
            if !isCompleted {
                self.log(message: "Server config download failed.Using last stored config from storage", logLevel: .debug)
            }
        }
    }
    
    private func fetchServerConfig() -> RSServerConfig? {
        var serverConfig: RSServerConfig?
        let semaphore = DispatchSemaphore(value: 0)
        let serviceManager = RSServiceManager(client: self)
        serviceManager.downloadServerConfig { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let config):
                serverConfig = config
                self.update(serverConfig: config, type: .refresh)
            case .failure(let error):
                self.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        return serverConfig
    }
}
