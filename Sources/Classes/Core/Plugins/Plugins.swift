//
//  RSPlugins.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public enum PluginType: CaseIterable {
    case `default`
    case destination
}

public protocol Plugin: AnyObject {
    var type: PluginType { get set }
    var client: RSClientProtocol? { get set }
    var sourceConfig: SourceConfig? { get set }
    func process<T: Message>(message: T?) -> T?
}

public extension Plugin {
    func process<T: Message>(message: T?) -> T? {
        return message
    }
}

public protocol MessagePlugin: Plugin {
    func identify(message: IdentifyMessage) -> IdentifyMessage?
    func track(message: TrackMessage) -> TrackMessage?
    func group(message: GroupMessage) -> GroupMessage?
    func alias(message: AliasMessage) -> AliasMessage?
    func screen(message: ScreenMessage) -> ScreenMessage?
}

public extension MessagePlugin {
    func process<T: Message>(message: T?) -> T? {
        var msg: T? = message
        switch msg {
        case let e as TrackMessage:
            msg = track(message: e) as? T
        case let e as IdentifyMessage:
            msg = identify(message: e) as? T
        case let e as ScreenMessage:
            msg = screen(message: e) as? T
        case let e as GroupMessage:
            msg = group(message: e) as? T
        case let e as AliasMessage:
            msg = alias(message: e) as? T
        default:
            break
        }
        return msg
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        return message
    }
    
    func group(message: GroupMessage) -> GroupMessage? {
        return message
    }
    
    func alias(message: AliasMessage) -> AliasMessage? {
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        return message
    }
}

public protocol DestinationPlugin: MessagePlugin {
    var name: String { get }
    var plugins: [Plugin] { get set }
    func add(plugin: Plugin)
    func associate(handler: (Plugin) -> Void)
    func reset()
    func flush()
}

public extension DestinationPlugin {
    func add(plugin: Plugin) {
        if let client = client {
            plugin.client = client
        }
        plugins.append(plugin)
    }
    
    func associate(handler: (Plugin) -> Void) {
        plugins.forEach({ handler($0) })
    }
    
    func reset() { }
    func flush() { }
}
