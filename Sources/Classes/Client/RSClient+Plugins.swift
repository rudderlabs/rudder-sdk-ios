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

            self.downloadServerConfig(retryCount: 0) { }
        }
    }
    
    private func downloadServerConfig(retryCount: Int, completion: @escaping () -> Void) {
        if isUnitTesting {
            checkServerConfigForUnitTesting(completion: completion)
            return
        }
        let maxRetryCount = 4
        
        guard retryCount < maxRetryCount else {
            Logger.log(message: "Server config download failed.", logLevel: .debug)
            completion()
            return
        }
        
        serviceManager?.downloadServerConfig({ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverConfig):
                Logger.log(message: "Server config download successful.", logLevel: .debug)
                self.serverConfig = serverConfig
                self.update(serverConfig: serverConfig, type: .refresh)
                self.userDefaults.write(.serverConfig, value: serverConfig)
                self.isServerConfigCached = true
                completion()
                    
            case .failure(let error):
                if error.code == RSErrorCode.WRONG_WRITE_KEY.rawValue {
                    Logger.log(message: "Wrong write key", logLevel: .error)
                    self.downloadServerConfig(retryCount: maxRetryCount, completion: completion)
                } else {
                    Logger.log(message: "Retrying download in \(retryCount) seconds", logLevel: .debug)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(retryCount)) {
                        self.downloadServerConfig(retryCount: retryCount + 1, completion: completion)
                    }
                }
            }
        })
    }
    
    private func checkServerConfigForUnitTesting(completion: @escaping () -> Void) {
        var configFileName = ""
        switch RSClient.sourceConfigType {
        default:
            configFileName = "ServerConfig"
        }
        
        let path = TestUtils.shared.getPath(forResource: configFileName, ofType: "json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let serverConfig = try JSONDecoder().decode(RSServerConfig.self, from: data)
            self.serverConfig = serverConfig
            self.update(serverConfig: serverConfig, type: .initial)
            self.userDefaults.write(.serverConfig, value: serverConfig)
        } catch { }
        
        completion()
    }
}

extension RSClient {
    static var sourceConfigType: SourceConfigType = .standard
}

// swiftlint:disable inclusive_language
enum SourceConfigType {
    case whiteList
    case blackList
    case standard
}
