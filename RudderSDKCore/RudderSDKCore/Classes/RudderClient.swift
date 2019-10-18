//
//  RudderClient.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 09/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import UIKit

@objcMembers public class RudderClient: NSObject {
    
    private static var instance: RudderClient? = nil;
    private var repository: EventRepository? = nil
    
    private override init() {
        // do nothing
    }
    
    private init(writeKey: String, config: RudderConfig) {
        // initiate things
        self.repository = EventRepository(_writeKey: writeKey, _config: config)
    }
    
    /*
     * API for getting instance of RudderClient with writeKey (bare minimum)
     * */
    @objc public static func getInstance(writeKey: String) -> RudderClient {
        return getInstance(writeKey: writeKey, config: RudderConfig())
    }
    
    /*
     * API for getting instance of RudderClient with config
     * */
    public static func getInstance(writeKey: String, builder: RudderConfig.Builder) -> RudderClient {
        return getInstance(writeKey: writeKey, config: builder.build())
    }
    
    /*
     * API for getting instance of RudderClient with config
     * */
    public static func getInstance(writeKey: String, config: RudderConfig) -> RudderClient {
        if (instance == nil) {
            instance = RudderClient(writeKey: writeKey, config: config)
        }
        
        return instance!
    }
    
    /*
     * package private api to be used in EventRepository
     * */
    static func getInstance() -> RudderClient? {
        return instance
    }
    
    
    /*
     * method for `track` messages
     * */
    public func track(message: RudderMessage) {
        message.setEventType(type: MessageType.TRACK)
        do {
            try self.repository?.dump(message: message)
        } catch {
            RudderLogger.logError(error: error)
        }
    }
    
    public func track(builder: RudderMessageBuilder) {
        self.track(message: builder.build())
    }
    
    /*
     * segment equivalent API
     * */
    public func track(event: String) {
        let message: RudderMessage = RudderMessageBuilder()
        .withEventName(eventName: event)
        .build()
        self.track(message: message)
    }
    
    public func track(event: String, property: Dictionary<String, NSObject>?) {
        let message: RudderMessage = RudderMessageBuilder()
        .withEventName(eventName: event)
        .withEventProperties(properties: property)
        .build()
        self.track(message: message)
    }
    
    public func track(event: String, property: Dictionary<String, NSObject>?, options: Dictionary<String, NSObject>?) {
        let message: RudderMessage = RudderMessageBuilder()
            .withEventName(eventName: event)
            .withEventProperties(properties: property)
            .withOptions(options: options)
            .build()
        self.track(message: message)
    }
    
    
    /*
     * method for `screen` messages
     * */
    public func screen(message: RudderMessage) {
        message.setEventType(type: MessageType.SCREEN)
        do {
            try self.repository?.dump(message: message)
        } catch {
            RudderLogger.logError(error: error)
        }
    }
    
    public func screen(builder: RudderMessageBuilder) {
        self.screen(message: builder.build())
    }
    
    /*
     * segment equivalent API
     * */
    public func screen(event: String) {
        let message: RudderMessage = RudderMessageBuilder()
            .withEventName(eventName: event)
            .build()
        self.screen(message: message)
    }
    
    public func screen(event: String, property: Dictionary<String, NSObject>?) {
        let message: RudderMessage = RudderMessageBuilder()
            .withEventName(eventName: event)
            .withEventProperties(properties: property)
            .build()
        self.screen(message: message)
    }
    
    public func screen(event: String, category: String, property: Dictionary<String, NSObject>?, options: Dictionary<String, NSObject>?) {
        let message: RudderMessage = RudderMessageBuilder()
            .withEventName(eventName: event)
            .withEventProperties(properties: property)
            .withEventProperty(key: "category", value: category as NSObject)
            .withOptions(options: options)
            .build()
        self.screen(message: message)
    }
    
    public func screen(event: String, property: Dictionary<String, NSObject>?, options: Dictionary<String, NSObject>?) {
        let message: RudderMessage = RudderMessageBuilder()
            .withEventName(eventName: event)
            .withEventProperties(properties: property)
            .withOptions(options: options)
            .build()
        self.screen(message: message)
    }
    
    /*
     * method for `page` messages
     * */
    public func page(message: RudderMessage) {
        message.setEventType(type: MessageType.PAGE)
        do {
            try self.repository?.dump(message: message)
        } catch {
            RudderLogger.logError(error: error)
        }
    }
    
    public func page(builder: RudderMessageBuilder) {
        self.page(message: builder.build())
    }
    
    /*
     * method for `identify` messages
     * */
    @objc public func identify(message: RudderMessage) {
        
    }
    
    @objc public func identify(builder: RudderMessageBuilder) {
        
    }
    
    @objc public func identify(traits: RudderTraits, options: AnyCodable) {
        
    }
    
    //public func identify(builder: RudderTraitsBuilder) {
        
    //}
    
    public func identify(userId: String) {
        
    }
    
    /*
     * segment equivalent API
     * */
    public func alias(event: String) {
        // to be decided
    }
    
    public func alias(event: String, options: AnyCodable) {
        // to be decided
    }
    
    public func group(groupId: String) {
        // to be decided
    }
    
    public func group(groupId: String, traits: RudderTraits) {
        // to be decided
    }
    
    public func group(groupId: String, traits: RudderTraits, options: AnyCodable?) {
        // to be decided
    }
    
    public static func setSingletonInstance(_instance: RudderClient?) {
        if (_instance != nil) {
            instance = _instance
        }
    }
    
    public func getRudderContext() -> RudderContext {
        return RudderElementCache.getCachedContext()
    }
    
    public func optOut() {
        // to be decided
    }
    
    public func reset() {

    }
    
    public func shutdown() {
        
    }
    
    public class Builder {
        private var writeKey: String
        
        public init(writeKey: String) {
            self.writeKey = writeKey
        }
        
        private var trackLifecycleEvents: Bool = false
        
        public func trackApplicationLifecycleEvents() -> Builder {
            self.trackLifecycleEvents = true
            return self
        }
        
        private var recordScreenView: Bool = false
        
        public func recordScreenViews() -> Builder {
            self.recordScreenView = true
            return self
        }
        
        private var config: RudderConfig? = nil
        
        public func withRudderConfig(config: RudderConfig) -> Builder {
            self.config = config
            return self
        }
        
        public func withRudderConfigBuilder(builder: RudderConfig.Builder) -> Builder {
            self.config = builder.build()
            return self
        }
        
        public func build() -> RudderClient {
            if (self.config == nil) {
                self.config = RudderConfig()
            }
            
            return RudderClient.getInstance(writeKey: self.writeKey, config: self.config!)
        }
    }
}
