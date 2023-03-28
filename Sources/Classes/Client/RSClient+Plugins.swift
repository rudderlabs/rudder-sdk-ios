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
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            guard let app = notification.object as? UIApplication else { return }
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
        RSRepeatingTimer.schedule(interval: .days(1), queue: .main) {
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
        assert(Thread.isMainThread)
        guard !self.checkServerConfigInProgress else { return }
        
        self.checkServerConfigInProgress = true
        self.checkServerConfig(retryCount: 0) {
            assert(Thread.isMainThread)
            self.checkServerConfigInProgress = false
        }
    }
    
    private func checkServerConfig(retryCount: Int, completion: @escaping ( ) -> Void) {
        assert(Thread.isMainThread)
        let maxRetryCount = 4
        
        guard retryCount < maxRetryCount else {
            log(message: "Server config download failed. Using last stored config from storage", logLevel: .debug)
            completion()
            return
        }
        
        fetchServerConfig { result in
            assert(Thread.isMainThread)
            
            switch result {
            case .success(let serverConfig):
                self.update(serverConfig: serverConfig, type: .refresh)
                self.serverConfig = serverConfig
                RSUserDefaults.saveServerConfig(serverConfig)
                RSUserDefaults.updateLastUpdatedTime(RSUtils.getTimeStamp())
                self.log(message: "server config download successful", logLevel: .debug)
                completion()
                
            case .failure(let error):
                if error.code == RSErrorCode.WRONG_WRITE_KEY.rawValue {
                    self.log(message: "Wrong write key", logLevel: .error)
                    self.checkServerConfig(retryCount: maxRetryCount, completion: completion)
                } else {
                    self.log(message: "Retrying download in \(retryCount) seconds", logLevel: .debug)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(retryCount)) {
                        self.checkServerConfig(retryCount: retryCount + 1, completion: completion)
                    }
                }
            }
        }
    }
    
    private func fetchServerConfig(completion: @escaping (HandlerResult<RSServerConfig, NSError>) -> Void) {
        let serviceManager = RSServiceManager(client: self)
        serviceManager.downloadServerConfig { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
