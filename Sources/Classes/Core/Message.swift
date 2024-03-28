//
//  Message.swift
//  Rudder
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public enum MessageType: String {
    case track
    case screen
    case identify
    case group
    case alias
}

public protocol Message {
    var type: MessageType { get set }
    var anonymousId: String? { get set }
    var messageId: String? { get set }
    var userId: String? { get set }
    var timestamp: String? { get set }
    var context: MessageContext? { get set }
    var integrations: MessageIntegrations? { get set }
    var option: MessageOptionType? { get set }
    var channel: String? { get set }
    var dictionaryValue: [String: Any] { get }
    var sessionId: Int? { get set }
    var sessionStart: Bool? { get set }
}

public struct TrackMessage: Message {
    public var type: MessageType = .track
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: MessageOptionType?
    public var channel: String?
    public var sessionId: Int?
    public var sessionStart: Bool?
    
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
    
    init(event: String, properties: TrackProperties? = nil, option: MessageOptionType? = nil) {
        self.event = event
        self.properties = properties
        self.option = option
    }
}

public struct IdentifyMessage: Message {
    public var type: MessageType = .identify
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: MessageOptionType?
    public var channel: String?
    public var sessionId: Int?
    public var sessionStart: Bool?
    
    public var traits: IdentifyTraits?
    
    public var dictionaryValue: [String: Any] {
        var dictionary = staticDictionary()
        dynamicDictionary(dictionary: &dictionary)
        return dictionary
    }
    
    private func dynamicDictionary(dictionary: inout [String: Any]) {
        dictionary["event"] = "identify"
    }
    
    init(userId: String, traits: IdentifyTraits? = nil, option: MessageOptionType? = nil) {
        self.userId = userId
        self.traits = traits
        self.option = option
    }
}

public struct ScreenMessage: Message {
    public var type: MessageType = .screen
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: MessageOptionType?
    public var channel: String?
    public var sessionId: Int?
    public var sessionStart: Bool?
    
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
    
    init(title: String, category: String? = nil, properties: ScreenProperties? = nil, option: MessageOptionType? = nil) {
        self.name = title
        self.category = category
        self.properties = properties
        self.option = option
    }
}

public struct GroupMessage: Message {
    public var type: MessageType = .group
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: MessageOptionType?
    public var channel: String?
    public var sessionId: Int?
    public var sessionStart: Bool?
    
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
    
    init(groupId: String, traits: GroupTraits? = nil, option: MessageOptionType? = nil) {
        self.groupId = groupId
        self.traits = traits
        self.option = option
    }
}

public struct AliasMessage: Message {
    public var type: MessageType = .alias
    public var anonymousId: String?
    public var messageId: String?
    public var userId: String?
    public var timestamp: String?
    public var context: MessageContext?
    public var integrations: MessageIntegrations?
    public var option: MessageOptionType?
    public var channel: String?
    public var sessionId: Int?
    public var sessionStart: Bool?
    
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
        
    init(newId: String, previousId: String? = nil, option: MessageOptionType? = nil) {
        self.userId = newId
        self.previousId = previousId
        self.option = option
    }    
}

// MARK: - RawEvent data helpers

extension Message {
    internal func applyRawEventData(userInfo: UserInfo?) -> Self {
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
        result.userId = userInfo?.userId
        result.anonymousId = userInfo?.anonymousId
        result.messageId = Utility.getUniqueId()
        result.timestamp = Utility.getTimestampString()
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
    
    var toString: Result<String, Error> {
        guard let jsonObject = Utility.handleUrlAndDateTypes(dictionaryValue), JSONSerialization.isValidJSONObject(jsonObject) else {
            return .failure(InternalErrors.invalidJSON)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return .failure(InternalErrors.invalidJSON)
            }
            
            guard jsonString.getUTF8Length() <= Constants.messageSize.default else {
                return .failure(InternalErrors.maxBatchSize)
            }
            return .success(jsonString)
        } catch {
            return .failure(InternalErrors.failedJSONSerialization(error))
        }
    }
}

extension Utility {
    static func handleUrlAndDateTypes(_ message: [String: Any]?) -> [String: Any]? {
        if var workingMessage = message {
            for (key, value) in workingMessage {
                if var dictValue = value as? [String: Any] {
                    convertIntoString(&dictValue)
                    workingMessage[key] = dictValue
                }
            }
            return workingMessage
        }
        return nil
    }
    
    static func convertIntoString(_ dictValue: inout [String: Any]) {
        for (key, value) in dictValue {
            if var nestedDictValue = value as? [String: Any] {
                convertIntoString(&nestedDictValue)
                dictValue[key] = nestedDictValue
            } else if let dateValue = value as? Date {
                let dateFormatter = ISO8601DateFormatter()
                dictValue[key] = dateFormatter.string(from: dateValue)
            } else if let urlValue = value as? URL {
                dictValue[key] = urlValue.absoluteString
            }
        }
    }
}
