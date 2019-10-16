    //
//  RudderElementBuilder.swift
//  RudderPlugin_iOS
//
//  Created by Arnab Pal on 14/09/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

@objc public class RudderMessageBuilder : NSObject {
    @objc public override init() {
        
    }
    
    private var eventName: String? = nil
    
    @objc public func withEventName(eventName: String) -> RudderMessageBuilder {
        self.eventName = eventName
        return self
    }
    
    private var userId: String? = nil
    
    @objc public func withUserId(userId: String) -> RudderMessageBuilder {
        self.userId = userId
        return self
    }
    
    private var eventProperties: Dictionary<String, NSObject>? = nil
    @objc public func withEventProperties(properties: Dictionary<String, NSObject>?) -> RudderMessageBuilder {
        self.eventProperties = properties
        return self
    }
    
    @objc public func withEventProperty(key: String, value: NSObject) -> RudderMessageBuilder {
        if(self.eventProperties == nil) {
            self.eventProperties = Dictionary()
        }
        self.eventProperties![key] = value
        return self
    }
    
    private var userProperties: Dictionary<String, NSObject>? = nil
    @objc public func withUserProperties(properties: Dictionary<String, NSObject>) -> RudderMessageBuilder {
        self.userProperties = properties
        return self
    }
    
    @objc public func withUserProperty(key: String, value: NSObject) -> RudderMessageBuilder {
        if (self.userProperties == nil) {
            self.userProperties = Dictionary()
        }
        self.userProperties![key] = value
        return self
    }
    
    private var integrations: Dictionary<String, Bool>? = nil
    @objc public func withIntegration(integrations: Dictionary<String, Bool>) -> RudderMessageBuilder {
        self.integrations = integrations
        return self
    }
    
    @objc public func withIntegration(integration: String, isEnabled: Bool) -> RudderMessageBuilder {
        if (self.integrations == nil) {
            self.integrations = Dictionary()
        }
        self.integrations![integration] = isEnabled
        return self
    }
    
    private var options: Dictionary<String, NSObject>? = nil
    @objc public func withOptions(options: Dictionary<String, NSObject>?) -> RudderMessageBuilder {
        self.options = options
        return self
    }
    
    @objc public func build() -> RudderMessage {
        let element = RudderMessage()
        if (self.eventName != nil) {
            element.setEventName(eventName: self.eventName!)
        }
        if (self.userId != nil) {
            element.setUserId(userId: self.userId!)
        }
        if (self.eventProperties != nil) {
            element.setEventProperties(eventProperties: AnyCodable(value: self.eventProperties!))
        }
        if (self.userProperties != nil) {
            element.setUserProperties(userProperties: AnyCodable(value: self.userProperties!))
        }
        if (self.integrations != nil) {
            element.setIntegrations(integrations: AnyCodable(value: self.integrations!))
        }
        return element
    }
}
