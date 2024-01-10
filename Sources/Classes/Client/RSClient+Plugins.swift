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
        add(plugin: RSIntegrationPlugin())
        add(plugin: RudderDestinationPlugin())
        add(plugin: RSUserSessionPlugin())
        
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

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst) || os(watchOS)
import UIKit
extension RSClient {
    internal func setupServerConfigCheck() {
        setupDownloadServerConfig()
    }
}

#elseif os(macOS)
import Cocoa
extension RSClient {
    internal func setupServerConfigCheck() {
        setupDownloadServerConfig()
        RSRepeatingTimer.schedule(interval: .days(1), queue: .main) { [weak self] in
            guard let self = self else { return }
            self.setupDownloadServerConfig()
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
        // if the server config is not cached. we send the updateType to external destination as initial
        var updateType = type
        if !isServerConfigCached, type == .refresh, let destination = plugin as? RSDestinationPlugin, destination.key != RUDDER_DESTINATION_KEY {
            updateType = .initial
        }
        plugin.update(serverConfig: serverConfig, type: updateType)
        if let dest = plugin as? RSDestinationPlugin {
            dest.apply { subPlugin in
                subPlugin.update(serverConfig: serverConfig, type: updateType)
            }
        }
    }
    
    func setupDownloadServerConfig() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.downloadServerConfig(retryCount: 0) {
                // we can remove completion in future. at this moment, we are keeping it.
            }
        }
    }
    
    private func downloadServerConfig(retryCount: Int, completion: @escaping () -> Void) {
        downloadServerConfig?.downloadServerConfig(retryCount: retryCount, completion: { [weak self] serverConfig in
            guard let self = self, let serverConfig = serverConfig else {
                completion()
                return
            }
            
            Logger.log(message: "Server config download successful.", logLevel: .debug)
            self.serverConfig = serverConfig
            self.update(serverConfig: serverConfig, type: .refresh)
            self.userDefaults?.write(.serverConfig, value: serverConfig)
            self.isServerConfigCached = true
            completion()
        })
    }
}
