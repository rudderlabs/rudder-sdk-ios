//
//  Option.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation


public struct ExternalId: Codable {
    let type: String
    let id: String
}

public protocol GlobalOptionType {
    /**
        ``integrationsStatus`` object is used to enable/disable sending events to any destination from the Client Side
        Eg: `["Amplitude" : true, "Adjust": false]`
        The above example would mean that the destination `Amplitude` is enabled and the destination `Adjust` is disabled.
        If the above example value is passed as part of ``GlobalOptionType``, it would be applied to all the events made in a session of SDK initialization, unless overridden by the ``MessageOptionType`` at an event level.
           
         If ``integrationsStatus`` is passed as part of ``MessageOptionType``, it would be applied only for that particular message.
     */
    
    var integrationsStatus: [String: Bool]? { get }
    
    /**
        ``customContexts`` helps you to set an object which can be added to `context` object of the payload generated for all the types of events. If this is passed as part of ``GlobalOptionType`` this would be applied to all the events made in a session of SDK initialization, unless overridden by the ``MessageOptionType`` at an event level.
     
         If ``customContexts``  is passed as part of ``MessageOptionType``, it would be applied only for that particular message.
     */
    var customContexts: [String: Any]? { get }
}

public protocol MessageOptionType: GlobalOptionType {
    /**
         ``externalIds`` are sometimes used to add new identifiers to the current user which can be used by the Cloud mode destinations.
          -  These values can be passed only via an event level API and cannot be passed with SDK initialization.
          -  If ``externalIds`` are passed as part of `Identify` event, they are persisted and attached along with every event made until the user logs out by calling `Reset`
          -  If ``externalIds`` are passed as part of any other event, then they are applied only for that particular event, and if any persisted externalIds exists from any previous `Identify` call, they are overriden just for the current event.
     */
    var externalIds: [ExternalId]? { get }
}

public class GlobalOption: GlobalOptionType {
    
    public init() {}
    
    private var _integrationsStatus: [String: Bool]?
    private var _customContexts: [String: Any]?
    
    public var integrationsStatus: [String: Bool]? {
        _integrationsStatus
    }
    
    public var customContexts: [String: Any]? {
        _customContexts
    }
    
    @discardableResult
    public func putIntegrationStatus(_ name: String, isEnabled: Bool) -> Self {
        guard name.isNotEmpty else {
            return self
        }
        if _integrationsStatus == nil {
            _integrationsStatus = [String: Bool]()
        }
        _integrationsStatus?[name] = isEnabled
        return self
    }
    
    @discardableResult
    public func putCustomContext(_ context: [String: Any], for key: String) -> Self {
        guard key.isNotEmpty else {
            return self
        }
        if _customContexts == nil {
            _customContexts = [String: Any]()
        }
        _customContexts?[key] = context
        return self
    }
}

public class MessageOption: GlobalOption, MessageOptionType {
    
    public override init() {}
    
    private var _externalIds: [ExternalId]?
    
    public var externalIds: [ExternalId]? {
        _externalIds
    }

    @discardableResult
    public func putExternalId(_ id: String, to type: String) -> MessageOption {
        guard type.isNotEmpty, id.isNotEmpty else {
            return self
        }
        if _externalIds == nil {
            _externalIds = [ExternalId]()
        }
        
        _externalIds?.add(ExternalId(type: type, id: id))
        return self
    }
}


extension [ExternalId] {
    mutating func add(_ externalId: ExternalId) {
        if let index = self.firstIndex(where: { $0.type == externalId.type }) {
            // Update the externalId, if an externalId with the same type already exists
            self[index] = externalId
        } else {
            // Append the new externalId to the array
            self.append(externalId)
        }
    }
    
    mutating func add(_ externalIds: [ExternalId]) {
        for externalId in externalIds {
            add(externalId)
        }
    }
}
