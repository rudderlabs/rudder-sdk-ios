//
//  Timeline.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public class RSController {
    let plugins: [PluginType: Mediator]
    
    public init() {
        self.plugins = [
            .before: Mediator(),
            .enrichment: Mediator(),
            .destination: Mediator(),
            .after: Mediator(),
            .utility: Mediator()
        ]
    }
    
    @discardableResult
    func process<E: RSMessage>(incomingEvent: E) -> E? {
        // apply .before and .enrichment types first ...
        let beforeResult = applyPlugins(type: .before, event: incomingEvent)
        
        // once the event enters a destination, we don't want
        // to know about changes that happen there. those changes
        // are to only be received by the destination.
        _ = applyPlugins(type: .destination, event: beforeResult)
        
        // apply .after plugins ...
        let afterResult = applyPlugins(type: .after, event: beforeResult)

        return afterResult
    }
    
    // helper method used by DestinationPlugins and Timeline
    func applyPlugins<E: RSMessage>(type: PluginType, event: E?) -> E? {
        var result: E? = event
        if let mediator = plugins[type], let e = event {
            result = mediator.execute(message: e)
        }
        return result
    }
}

class Mediator {
    func add(plugin: RSPlugin) {
        plugins.append(plugin)
        if let option = plugin.client?.serverConfig {
            plugin.update(serverConfig: option, type: .initial)
        }
    }
    
    func remove(plugin: RSPlugin) {
        plugins.removeAll { (storedPlugin) -> Bool in
            return plugin === storedPlugin
        }
    }

    var plugins = [RSPlugin]()
    func execute<T: RSMessage>(message: T) -> T? {
        var result: T? = message
        
        plugins.forEach { (plugin) in
            if let r = result {
                // Drop the event return because we don't care about the
                // final result.
                if plugin is RSDestinationPlugin {
                    _ = plugin.execute(message: r)
                } else {
                    result = plugin.execute(message: r)
                }
            }
        }
        
        return result
    }
}

// MARK: - Plugin Support

extension RSController {
    func apply(_ closure: (RSPlugin) -> Void) {
        for type in PluginType.allCases {
            if let mediator = plugins[type] {
                mediator.plugins.forEach { (plugin) in
                    closure(plugin)
                    if let destPlugin = plugin as? RSDestinationPlugin {
                        destPlugin.apply(closure: closure)
                    }
                }
            }
        }
    }
    
    func add(plugin: RSPlugin) {
        if let mediator = plugins[plugin.type] {
            mediator.add(plugin: plugin)
        }
    }
    
    func remove(plugin: RSPlugin) {
        // remove all plugins with this name in every category
        for type in PluginType.allCases {
            if let mediator = plugins[type] {
                let toRemove = mediator.plugins.filter { (storedPlugin) -> Bool in
                    return plugin === storedPlugin
                }
                toRemove.forEach { (plugin) in
                    plugin.shutdown()
                    mediator.remove(plugin: plugin)
                }
            }
        }
    }
    
    func find<T: RSPlugin>(pluginType: T.Type) -> T? {
        var found = [RSPlugin]()
        for type in PluginType.allCases {
            if let mediator = plugins[type] {
                found.append(contentsOf: mediator.plugins.filter { (plugin) -> Bool in
                    return plugin is T
                })
            }
        }
        return found.first as? T
    }
}

// MARK: - Plugin Timeline Execution

public extension RSEventPlugin {
    func execute<T: RSMessage>(message: T?) -> T? {
        var result: T? = message
        switch result {
        case let r as IdentifyMessage:
            result = self.identify(message: r) as? T
        case let r as TrackMessage:
            result = self.track(message: r) as? T
        case let r as ScreenMessage:
            result = self.screen(message: r) as? T
        case let r as AliasMessage:
            result = self.alias(message: r) as? T
        case let r as GroupMessage:
            result = self.group(message: r) as? T
        default:
            break
        }
        return result
    }

    // Default implementations that forward the event. This gives plugin
    // implementors the chance to interject on an event.
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        return message
    }
    
    func group(message: GroupMessage) -> GroupMessage? {
        return message
    }
    
    func alias(message: AliasMessage) -> AliasMessage? {
        return message
    }
    
    func flush() { }
    func reset() { }
}

// MARK: - Destination Timeline

extension RSDestinationPlugin {
    public func execute<T: RSMessage>(message: T?) -> T? {
        var result: T? = message
        if let r = result {
            result = self.process(incomingEvent: r)
        }
        return result
    }
    
    func isDestinationEnabled(message: RSMessage) -> Bool {
        var customerDisabled = false
        
        if let integration = message.integrations?.first(where: { key, _ in
            return key == self.key
        }), integration.value == false {
            customerDisabled = true
        }
        
        var hasSettings = false        
        if let destinations = client?.serverConfig?.destinations {
            if let destination = destinations.first(where: { $0.destinationDefinition?.displayName == self.key }), destination.enabled {
                hasSettings = true
            }
        }
        
        return !customerDisabled || (hasSettings && !customerDisabled)
    }
    
    // swiftlint:disable inclusive_language
    func isEventAllowed(message: RSMessage) -> Bool {
        func isAllowed(message: RSMessage, list: [String]) -> Bool {
            switch message {
            case let e as TrackMessage:
                return list.contains(e.event)                
            case let e as ScreenMessage:
                return list.contains(e.name)
            default:
                break
            }
            return true
        }
        
        var isEventAllowed = true
        if let destinations = client?.serverConfig?.destinations {
            if let destination = destinations.first(where: { $0.destinationDefinition?.displayName == self.key }) {
                switch destination.eventFilteringOption {
                case .disabled:
                    break
                case .blackListed:
                    if let blackListedEvents = destination.blackListedEvents {
                        isEventAllowed = !isAllowed(message: message, list: blackListedEvents)
                    }
                case .whiteListed:
                    if let whiteListedEvents = destination.whiteListedEvents {
                        isEventAllowed = isAllowed(message: message, list: whiteListedEvents)
                    }
                }
            }
        }
        return isEventAllowed
    }

    func process<E: RSMessage>(incomingEvent: E) -> E? {
        // This will process plugins (think destination middleware) that are tied
        // to this destination.
        
        var result: E?
        
        if isDestinationEnabled(message: incomingEvent) {
            // check event is allowed
            if isEventAllowed(message: incomingEvent) {
                // apply .before and .enrichment types first ...
                let beforeResult = controller.applyPlugins(type: .before, event: incomingEvent)
                let enrichmentResult = controller.applyPlugins(type: .enrichment, event: beforeResult)
                
                // now we execute any overrides we may have made.  basically, the idea is to take an
                // incoming event, like identify, and map it to whatever is appropriate for this destination.
                var destinationResult: E?
                switch enrichmentResult {
                case let e as IdentifyMessage:
                    destinationResult = identify(message: e) as? E
                case let e as TrackMessage:
                    destinationResult = track(message: e) as? E
                case let e as ScreenMessage:
                    destinationResult = screen(message: e) as? E
                case let e as GroupMessage:
                    destinationResult = group(message: e) as? E
                case let e as AliasMessage:
                    destinationResult = alias(message: e) as? E
                default:
                    break
                }
                
                // apply .after plugins ...
                result = controller.applyPlugins(type: .after, event: destinationResult)
            }
        }
        
        return result
    }
}
