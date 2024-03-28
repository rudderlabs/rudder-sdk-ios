//
//  RSClientMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
@testable import Rudder

class RSClientMock: RSClientProtocol {
    func track(_ eventName: String, properties: Rudder.TrackProperties?, option: MessageOptionType?) {
        let message = TrackMessage(event: eventName, properties: properties, option: option)
        process(message: message)
    }
    
    func identify(_ userId: String, traits: Rudder.IdentifyTraits?, option: MessageOptionType?) {
        let message = IdentifyMessage(userId: userId, traits: traits, option: option)
        process(message: message)
    }
    
    func screen(_ screenName: String, category: String?, properties: Rudder.ScreenProperties?, option: MessageOptionType?) {
        let message = ScreenMessage(title: screenName, category: category, properties: properties, option: option)
        process(message: message)
    }
    
    func group(_ groupId: String, traits: Rudder.GroupTraits?, option: MessageOptionType?) {
        let message = GroupMessage(groupId: groupId, traits: traits, option: option)
        process(message: message)
    }
    
    func alias(_ newId: String, option: MessageOptionType?) {
        let message = AliasMessage(newId: newId, option: option)
        process(message: message)
    }
    
    func process(message: Message) {
        switch message {
            case let e as TrackMessage:
                process(e)
            case let e as IdentifyMessage:
                process(e)
            case let e as ScreenMessage:
                process(e)
            case let e as GroupMessage:
                process(e)
            case let e as AliasMessage:
                process(e)
            default:
                break
        }
        
        @discardableResult
        func process<T: Message>(_ message: T) -> T? {
            let defaultMesage = register(message: message, for: .default)
            register(message: defaultMesage, for: .destination)
            
            @discardableResult
            func register(message: T?, for pluginType: PluginType) -> T? {
                if let list = pluginList[pluginType], let msg = message {
                    return list.process(message: msg)
                }
                return message
            }
            return defaultMesage
        }
    }
    
    var instanceName: String
    var configuration: Rudder.Configuration
    var userDefaultsWorker: Rudder.UserDefaultsWorkerProtocol
    var storageWorker: Rudder.StorageWorkerProtocol
    var sessionStorage: Rudder.SessionStorageProtocol
    let logger = Logger(logger: NOLogger())
    
    @ReadWriteLock var pluginList: [PluginType: [Plugin]] = [
        .default: [Plugin](),
        .destination: [Plugin]()
    ]
    
    init(
        instanceName: String = "dead",
        configuration: Rudder.Configuration = .mockAny(),
        userDefaultsWorker: Rudder.UserDefaultsWorkerProtocol = UserDefaultsWorkerMock(
            queue: DispatchQueue(
                label: "clientMock".queueLabel()
            )
        ),
        storageWorker: Rudder.StorageWorkerProtocol = StorageWorkerMock(),
        sessionStorage: Rudder.SessionStorageProtocol = SessionStorageMock()
    ) {
        self.instanceName = instanceName
        self.configuration = configuration
        self.userDefaultsWorker = userDefaultsWorker
        self.storageWorker = storageWorker
        self.sessionStorage = sessionStorage
    }
    
    func logDebug(_ message: String, file: String, function: String, line: Int) {
        logger.logDebug(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    func logInfo(_ message: String, file: String, function: String, line: Int) {
        logger.logInfo(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    func logWarning(_ message: String, file: String, function: String, line: Int) {
        logger.logWarning(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    func logError(_ message: String, file: String, function: String, line: Int) {
        logger.logError(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    func addPlugin(_ plugin: Rudder.Plugin) {
        if var list = pluginList[plugin.type] {
            list.addPlugin(plugin)
            pluginList[plugin.type] = list
        }
    }
    
    func removePlugin(_ plugin: Rudder.Plugin) {
        PluginType.allCases.forEach { pluginType in
            if var pluginList = pluginList[pluginType] {
                let removeList = pluginList.filter({ $0 === plugin })
                removeList.forEach({ pluginList.removePlugin($0) })
            }
        }
    }
    
    func getAllPlugins() -> [Plugin]? {
        return pluginList.flatMap { (_, value) in
            return value
        }
    }
    
    func getDestinationPlugins() -> [DestinationPlugin]? {
        return getPluginList(by: .destination) as? [DestinationPlugin]
    }
    
    func getDefaultPlugins() -> [Plugin]? {
        return getPluginList(by: .default)
    }
    
    func getPluginList(by pluginType: Rudder.PluginType) -> [Rudder.Plugin]? {
        return pluginList[pluginType]
    }
    
    func getPlugin<T>(type: T.Type) -> T? where T: Rudder.Plugin {
        var filteredList = [Plugin]()
        PluginType.allCases.forEach { pluginType in
            if let pluginList = pluginList[pluginType] {
                filteredList.append(contentsOf: pluginList.filter({ $0 is T }))
            }
        }
        return filteredList.first as? T
    }
    
    func associatePlugins(_ handler: (Rudder.Plugin) -> Void) {
        PluginType.allCases.forEach { pluginType in
            if let pluginList = pluginList[pluginType] {
                pluginList.forEach { plugin in
                    handler(plugin)
                    if let plugin = plugin as? DestinationPlugin {
                        plugin.associate(handler: handler)
                    }
                }
            }
        }
    }
    
    func updateSourceConfig(_ sourceConfig: SourceConfig) {
        pluginList.forEach { (_, value) in
            value.forEach { plugin in
                plugin.sourceConfig = sourceConfig
            }
        }
    }
}
