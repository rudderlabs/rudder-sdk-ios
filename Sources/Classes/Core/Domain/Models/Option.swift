//
//  Option.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol OptionType {
    var integrations: [String: Bool] { get }
}

public protocol MessageOptionType: OptionType {
    var customContexts: [String: Any]? { get }
}

public protocol IdentifyOptionType: MessageOptionType {
    var externalIds: [[String: String]]? { get }
}

public class Option: OptionType {
    private var _integrations: [String: Bool] = [String: Bool]()
    public var integrations: [String: Bool] {
        _integrations
    }
    
    public init() { }
    
    @discardableResult
    public func putIntegration(_ name: String, isEnabled: Bool) -> Option {
        guard name.isNotEmpty else {
            return self
        }
        _integrations[name] = isEnabled
        return self
    }
}

public class MessageOption: OptionType, MessageOptionType {
    private var _integrations: [String: Bool] = [String: Bool]()
    private var _customContexts: [String: Any]?
    
    public var integrations: [String: Bool] {
        _integrations
    }
    public var customContexts: [String: Any]? {
        _customContexts
    }
    
    public init() { }
    
    @discardableResult
    public func putIntegration(_ name: String, isEnabled: Bool) -> MessageOption {
        guard name.isNotEmpty else {
            return self
        }
        _integrations[name] = isEnabled
        return self
    }
    
    @discardableResult
    public func putCustomContext(_ context: [String: Any], for key: String) -> MessageOption {
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

public class IdentifyOption: OptionType, MessageOptionType, IdentifyOptionType {
    private var _integrations: [String: Bool] = [String: Bool]()
    private var _customContexts: [String: Any]?
    private var _externalIds: [[String: String]]?
    
    public var integrations: [String: Bool] {
        _integrations
    }
    public var customContexts: [String: Any]? {
        _customContexts
    }
    
    public var externalIds: [[String: String]]? {
        _externalIds
    }
    
    public init() { }
    
    @discardableResult
    public func putIntegration(_ name: String, isEnabled: Bool) -> IdentifyOption {
        guard name.isNotEmpty else {
            return self
        }
        _integrations[name] = isEnabled
        return self
    }
    
    @discardableResult
    public func putCustomContext(_ context: [String: Any], for key: String) -> IdentifyOption {
        guard key.isNotEmpty else {
            return self
        }
        if _customContexts == nil {
            _customContexts = [String: Any]()
        }
        _customContexts?[key] = context
        return self
    }
    
    @discardableResult
    public func putExternalId(_ id: String, to type: String) -> IdentifyOption {
        guard type.isNotEmpty, id.isNotEmpty else {
            return self
        }
        if _externalIds == nil {
            _externalIds = [[String: String]]()
        }
        if let index = _externalIds?.firstIndex(where: { dict in
            return dict["type"] == type
        }) {
            _externalIds?[index]["id"] = id
        } else {
            let dict = ["type": type, "id": id]
            _externalIds?.append(dict)
        }
        return self
    }
}
