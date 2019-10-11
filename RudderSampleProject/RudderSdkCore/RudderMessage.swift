//
//  RudderMessage.swift
//  RudderSample
//
//  Created by Arnab Pal on 10/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

@objc public class RudderMessage : NSObject, Encodable {
    let messageId: String = String(NSDate().timeIntervalSince1970) + "-" + UUID().uuidString.lowercased()
    var channel: String = "mobile"
    var context : RudderContext? = nil
    var type: String = ""
    let action: String = ""
    let timestamp: String = Utils.getTimeStampStr()
    var anonymousId: String = ""
    var userId: String = ""
    var event: String = ""
    var eventProperties: AnyCodable? = nil
    var userProperties: AnyCodable? = nil
    var integrations: AnyCodable? = nil
    
    override init() {
        self.context = RudderElementCache.getCachedContext()
        self.anonymousId = self.context!.deviceInfo.id
    }
    
    func setIntegrations(integrations: AnyCodable) {
        self.integrations = integrations
    }
    
    func setIntegrations(integrations: Dictionary<String, Bool>) {
        self.integrations = AnyCodable(value: integrations)
    }
    
    func setEventProperties(eventProperties: AnyCodable) {
        self.eventProperties = eventProperties
    }
    
    func setUserProperties(userProperties: AnyCodable) {
        self.userProperties = userProperties
    }
    
    func setEventType(type: String) {
        self.type = type
    }
    
    func setEventName(eventName: String) {
        self.event = eventName
    }
    
    func setUserId(userId: String) {
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case messageId = "messageId"
        case channel = "channel"
        case context = "context"
        case type = "type"
        case action = "action"
        case timestamp = "timestamp"
        case anonymousId = "anonymousId"
        case userId = "userId"
        case event = "event"
        case eventProperties = "properties"
        case userProperties = "userProperties"
        case integrations = "integrations"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(channel, forKey: .channel)
        try container.encode(context, forKey: .context)
        try container.encode(type, forKey: .type)
        try container.encode(action, forKey: .action)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(anonymousId, forKey: .anonymousId)
        try container.encode(userId, forKey: .userId)
        try container.encode(event, forKey: .event)
        try container.encode(eventProperties, forKey: .eventProperties)
        try container.encode(userProperties, forKey: .userProperties)
        try container.encode(integrations, forKey: .integrations)
    }
    
    
}
