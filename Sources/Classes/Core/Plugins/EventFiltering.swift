//
//  EventFiltering.swift
//  Rudder
//
//  Created by Pallab Maiti on 22/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension DestinationPlugin {
    public func process<T>(message: T?) -> T? where T: Message {
        var msg: T? = message
        if let m = msg {
            msg = filter(m)
        }
        return msg
    }
}

extension DestinationPlugin {
    private func isDestinationEnabled(message: Message) -> Bool {
        var customerDisabled: Bool?
        
        if let integration = message.integrations?.first(where: { key, _ in
            return key == self.name
        }), !integration.value {
            customerDisabled = true
        }
        
        var hasSettings: Bool?
        if let destinations = sourceConfig?.destinations, let destination = destinations.first(where: { $0.destinationDefinition?.displayName == self.name }), destination.enabled {
            hasSettings = true
        }
        
        if customerDisabled == nil, hasSettings == nil {
            return false
        }
        if let status = customerDisabled, status {
            return false
        }
        if let status = hasSettings, status {
            return true
        }
        return false
    }
    
    // swiftlint:disable inclusive_language
    private func shouldAllow(message: Message) -> Bool {
        guard let destinations = sourceConfig?.destinations, let destination = destinations.first(where: { $0.destinationDefinition?.displayName == self.name }) else {
            return true
        }
        var isEventAllowed = true
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
        return isEventAllowed
    }
    
    private func isAllowed(message: Message, list: [String]) -> Bool {
        if let e = message as? TrackMessage {
            return list.contains(e.event)
        }
        return true
    }
    
    private func filter<T: Message>(_ message: T) -> T? {
        guard isDestinationEnabled(message: message) else {
            client?.logDebug(LogMessages.destinationDisabled.description)
            return nil
        }
        
        guard shouldAllow(message: message) else {
            client?.logDebug(LogMessages.eventFiltered.description)
            return nil
        }
        
        var destinationMessage: T?
        switch message {
        case let e as IdentifyMessage:
            destinationMessage = identify(message: e) as? T
        case let e as TrackMessage:
            destinationMessage = track(message: e) as? T
        case let e as ScreenMessage:
            destinationMessage = screen(message: e) as? T
        case let e as GroupMessage:
            destinationMessage = group(message: e) as? T
        case let e as AliasMessage:
            destinationMessage = alias(message: e) as? T
        default:
            break
        }
        
        return destinationMessage
    }
}
