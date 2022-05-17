//
//  RSPlugins.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

/**
 PluginType specifies where in the chain a given plugin is to be executed.
 */
public enum PluginType: Int, CaseIterable {
    /// Executed before event processing begins.
    case before
    /// Executed as the first level of event processing.
    case enrichment
    /// Executed as events begin to pass off to destinations.
    case destination
    /// Executed after all event processing is completed.  This can be used to perform cleanup operations, etc.
    case after
    /// Executed only when called manually, such as Logging.
    case utility
}

public enum UpdateType {
    case initial
    case refresh
}

public protocol RSPlugin: AnyObject {
    var type: PluginType { get }
    var client: RSClient? { get set }
    
    func configure(client: RSClient)
    func update(serverConfig: RSServerConfig, type: UpdateType)
    func execute<T: RSMessage>(message: T?) -> T?
    func shutdown()
}

public extension RSPlugin {
    func execute<T: RSMessage>(message: T?) -> T? {
        return message
    }
    
    func update(serverConfig: RSServerConfig, type: UpdateType) { }

    func shutdown() { }
    
    func configure(client: RSClient) {
        self.client = client
    }
}

@objc
open class RudderDestination: NSObject {
    public var plugin: RSDestinationPlugin?
    
    public override init() {
        
    }
}

extension RSClient {
    @objc
    public func addDestination(_ destination: RudderDestination) {
        if let plugin = destination.plugin {
            add(plugin: plugin)
        }
    }
}

public protocol RSEventPlugin: RSPlugin {
    func identify(message: IdentifyMessage) -> IdentifyMessage?
    func track(message: TrackMessage) -> TrackMessage?
    func group(message: GroupMessage) -> GroupMessage?
    func alias(message: AliasMessage) -> AliasMessage?
    func screen(message: ScreenMessage) -> ScreenMessage?
    func reset()
    func flush()
}

public protocol RSDestinationPlugin: RSEventPlugin {
    var key: String { get }
    var controller: RSController { get }
    func add(plugin: RSPlugin) -> RSPlugin
    func apply(closure: (RSPlugin) -> Void)
    func remove(plugin: RSPlugin)
}

public protocol RSUtilityPlugin: RSEventPlugin { }

internal protocol RSPlatformPlugin: RSPlugin { }

public extension RSDestinationPlugin {
    func configure(client: RSClient) {
        self.client = client
        apply { plugin in
            plugin.configure(client: client)
        }
    }
    
    func apply(closure: (RSPlugin) -> Void) {
        controller.apply(closure)
    }
    
    @discardableResult
    func add(plugin: RSPlugin) -> RSPlugin {
        if let client = client {
            plugin.configure(client: client)
        }
        controller.add(plugin: plugin)
        return plugin
    }
    
    func remove(plugin: RSPlugin) {
        controller.remove(plugin: plugin)
    }
}
