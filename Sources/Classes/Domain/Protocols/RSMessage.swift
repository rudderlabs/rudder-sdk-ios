//
//  RSMessage.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol RSMessage {
    var type: RSMessageType { get set }
    var anonymousId: String? { get set }
    var messageId: String? { get set }
    var userId: String? { get set }
    var timestamp: String? { get set }
    var context: MessageContext? { get set }
    var integrations: MessageIntegrations? { get set }
    var option: RSOption? { get set }
    var channel: String? { get set }
    var dictionaryValue: [String: Any] { get }
}

public struct TrackMessage: RSMessage {
    public var type: RSMessageType = .track
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: RSOption?
    public var channel: String?
    
    public let event: String
    public let properties: TrackProperties?

    public var dictionaryValue: [String: Any] {
        var dictionary = staticDictionary()
        dynamicDictionary(dictionary: &dictionary)
        return dictionary
    }
    
    private func dynamicDictionary(dictionary: inout [String: Any]) {
        dictionary["event"] = event
        dictionary["properties"] = properties
    }
    
    init(event: String, properties: TrackProperties?, option: RSOption? = nil) {
        self.event = event
        self.properties = properties
        self.option = option
    }
}

public struct IdentifyMessage: RSMessage {
    public var type: RSMessageType = .identify
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: RSOption?
    public var channel: String?
    
    public var traits: IdentifyTraits?
    
    public var dictionaryValue: [String: Any] {
        var dictionary = staticDictionary()
        dynamicDictionary(dictionary: &dictionary)
        return dictionary
    }
    
    private func dynamicDictionary(dictionary: inout [String: Any]) {
        dictionary["event"] = "identify"
    }
    
    init(userId: String, traits: IdentifyTraits? = nil, option: RSOption? = nil) {
        self.userId = userId
        self.traits = traits
        self.option = option
    }
}

public struct ScreenMessage: RSMessage {
    public var type: RSMessageType = .screen
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: RSOption?
    public var channel: String?

    public let name: String
    public let category: String?
    public let properties: ScreenProperties?

    public var dictionaryValue: [String: Any] {
        var dictionary = staticDictionary()
        dynamicDictionary(dictionary: &dictionary)
        return dictionary
    }
    
    private func dynamicDictionary(dictionary: inout [String: Any]) {
        dictionary["properties"] = properties
        dictionary["event"] = name
        dictionary["category"] = category
    }
    
    init(title: String, category: String? = nil, properties: ScreenProperties? = nil, option: RSOption? = nil) {
        self.name = title
        self.category = category
        self.properties = properties
        self.option = option
    }
}

public struct GroupMessage: RSMessage {
    public var type: RSMessageType = .group
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: RSOption?
    public var channel: String?

    public let groupId: String
    public let traits: GroupTraits?
    
    public var dictionaryValue: [String: Any] {
        var dictionary = staticDictionary()
        dynamicDictionary(dictionary: &dictionary)
        return dictionary
    }
    
    private func dynamicDictionary(dictionary: inout [String: Any]) {
        dictionary["traits"] = traits
        dictionary["groupId"] = groupId
    }
    
    init(groupId: String, traits: GroupTraits? = nil, option: RSOption? = nil) {
        self.groupId = groupId
        self.traits = traits
        self.option = option
    }
}

public struct AliasMessage: RSMessage {
    public var type: RSMessageType = .alias
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: RSOption?
    public var channel: String?

    public var previousId: String?
    
    public var dictionaryValue: [String: Any] {
        var dictionary = staticDictionary()
        dynamicDictionary(dictionary: &dictionary)
        return dictionary
    }
    
    private func dynamicDictionary(dictionary: inout [String: Any]) {
        dictionary[keyPath: "context.traits.id"] = userId
        dictionary["previousId"] = previousId
    }
        
    init(newId: String, previousId: String?, option: RSOption? = nil) {
        self.userId = newId
        self.previousId = previousId
        self.option = option
    }    
}

// MARK: - RawEvent data helpers

extension RSMessage {
    internal func applyRawEventData(userInfo: RSUserInfo?) -> Self {
        var result: Self = self
        result.context = MessageContext()
        if let traits = userInfo?.traits?.dictionaryValue {
            result.context?[keyPath: "traits"] = traits
        }
        if let userId = userInfo?.userId {
            result.context?[keyPath: "traits.userId"] = userId
        }
        if let anonymousId = userInfo?.anonymousId {
            result.context?[keyPath: "traits.anonymousId"] = anonymousId
        }
        var device = [String: Any]()
        if let deviceToken: String = RSSessionStorage.shared.read(.deviceToken) {
            device["token"] = deviceToken
        }
        if let advertisingId: String = RSSessionStorage.shared.read(.advertisingId), advertisingId.isNotEmpty {
            device["advertisingId"] = advertisingId
            let appTrackingConsent: RSAppTrackingConsent = RSSessionStorage.shared.read(.appTrackingConsent) ?? .notDetermined
            device["attTrackingStatus"] = appTrackingConsent.rawValue
        }
        if !device.isEmpty {
            result.context?["device"] = device
        }
        result.userId = userInfo?.userId
        result.anonymousId = userInfo?.anonymousId
        result.messageId = "\(RSUtils.getTimeStamp())-\(RSUtils.getUniqueId())"
        result.timestamp = RSUtils.getTimestampString()
        result.channel = "mobile"
        return result
    }
    
    func staticDictionary() -> [String: Any] {
        var dict = ["messageId": messageId ?? "",
                    "channel": channel ?? "",
                    "originalTimestamp": timestamp ?? "",
                    "type": type.rawValue] as [String: Any]
        if let context = context {
            dict["context"] = context
        }
        if let integrations = integrations {
            dict["integrations"] = integrations
        }
        if let userId = userId {
            dict["userId"] = userId
        }
        if let anonymousId = anonymousId {
            dict["anonymousId"] = anonymousId
        }
        return dict
    }
}
