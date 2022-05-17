//
//  RSClient.swift
//  RudderStack
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc
open class RSClient: NSObject {
    var config: RSConfig?
    var controller: RSController
    var serverConfig: RSServerConfig?
    var error: NSError?
    static let shared = RSClient()
    
    private override init() {
        serverConfig = RSUserDefaults.getServerConfig()
        controller = RSController()
    }
    
    /**
     Returns the instance of RSClient.
     */
    @objc
    public static func sharedInstance() -> RSClient {
        return shared
    }
    
    /**
     Initialize this instance of RSClient with a given configuration setup.
     - Parameters:
        - config: The configuration to use
     # Example #
     ```
     let config: RSConfig = RSConfig(writeKey: WRITE_KEY)
                 .dataPlaneURL(DATA_PLANE_URL)
            
     RSClient.sharedInstance().configure(with: config)
     ```
     */
    @objc
    public func configure(with config: RSConfig) {
        self.config = config
        addPlugins()
    }
    
    /**
     API for track your event
     - Parameters:
        - eventName: Name of the event you want to track
        - properties: Properties you want to pass with the track call
        - option: Options related to this track call
     # Example #
     ```
     RSClient.sharedInstance().track("simple_track_with_props", properties: ["key_1": "value_1", "key_2": "value_2"], option: RSOption())
     ```
     */
    
    @objc
    public func track(_ eventName: String, properties: TrackProperties, option: RSOption) {
        _track(eventName, properties: properties, option: option)
    }
    
    @objc
    public func track(_ eventName: String, properties: TrackProperties) {
        _track(eventName, properties: properties, option: nil)
    }
    
    @objc
    public func track(_ eventName: String) {
        _track(eventName, properties: nil, option: nil)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - userId: User id of your user
        - traits: Other user properties
        - option: Options related to this identify call
     # Example #
     ```
     RSClient.sharedInstance().identify("user_id", traits: ["email": "abc@def.com"], option: RSOption())
     ```
     */
    
    @objc
    public func identify(_ userId: String, traits: IdentifyTraits, option: RSOption) {
        _identify(userId, traits: traits, option: option)
    }
    
    @objc
    public func identify(_ userId: String, traits: IdentifyTraits) {
        _identify(userId, traits: traits, option: nil)
    }
    
    @objc
    public func identify(_ userId: String) {
        _identify(userId, traits: nil, option: nil)
    }
    
    /**
     API for record screen
     - Parameters:
        - screenName: Name of the screen
        - properties: Properties you want to pass with the screen call
        - option: Options related to this screen call
     # Example #
     ```
     RSClient.sharedInstance().screen("ViewController", properties: ["key_1": "value_1", "key_2": "value_2"], option: RSOption())
     ```
     */
    
    @objc
    public func screen(_ screenName: String, category: String, properties: ScreenProperties, option: RSOption) {
        _screen(screenName, category: category, properties: properties, option: option)
    }
    
    @objc
    public func screen(_ screenName: String, category: String, properties: ScreenProperties) {
        _screen(screenName, category: category, properties: properties, option: nil)
    }
    
    @objc
    public func screen(_ screenName: String, properties: ScreenProperties) {
        _screen(screenName, category: nil, properties: properties, option: nil)
    }
    
    @objc
    public func screen(_ screenName: String, category: String) {
        _screen(screenName, category: category, properties: nil, option: nil)
    }
    
    @objc
    public func screen(_ screenName: String) {
        _screen(screenName, category: nil, properties: nil, option: nil)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - groupId: Group ID you want your user to attach to
        - traits: Traits of the group
        - option: Options related to this group call
     # Example #
     ```
     RSClient.sharedInstance().group("sample_group_id", traits: ["key_1": "value_1", "key_2": "value_2"], option: RSOption())
     ```
     */
    
    @objc
    public func group(_ groupId: String, traits: GroupTraits, option: RSOption) {
        _group(groupId, traits: traits, option: option)
    }
    
    @objc
    public func group(_ groupId: String, traits: GroupTraits) {
        _group(groupId, traits: traits, option: nil)
    }
    
    @objc
    public func group(_ groupId: String) {
        _group(groupId, traits: nil, option: nil)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - newId: New userId for the user
        - option: Options related to this alias call
     # Example #
     ```
     RSClient.sharedInstance().alias("user_id", option: RSOption())
     ```
     */
    
    @objc
    public func alias(_ newId: String, option: RSOption) {
        _alias(newId, option: option)
    }
    
    @objc
    public func alias(_ newId: String) {
        _alias(newId, option: nil)
    }
}

extension RSClient {
    internal func _track(_ eventName: String, properties: TrackProperties? = nil, option: RSOption? = nil) {
        guard eventName.isNotEmpty else {
            log(message: "eventName can not be empty", logLevel: .warning)
            return
        }
        let message = TrackMessage(event: eventName, properties: properties, option: option)
            .applyRawEventData()
        process(message: message)
    }
    
    internal func _screen(_ screenName: String, category: String? = nil, properties: ScreenProperties? = nil, option: RSOption? = nil) {
        guard screenName.isNotEmpty else {
            log(message: "screenName can not be empty", logLevel: .warning)
            return
        }
        let message = ScreenMessage(title: screenName, category: category, properties: properties, option: option)
            .applyRawEventData()
        process(message: message)
    }
    
    internal func _group(_ groupId: String, traits: [String: String]? = nil, option: RSOption? = nil) {
        guard groupId.isNotEmpty else {
            log(message: "groupId can not be empty", logLevel: .warning)
            return
        }
        let message = GroupMessage(groupId: groupId, traits: traits, option: option)
            .applyRawEventData()
        process(message: message)
    }
    
    internal func _alias(_ newId: String, option: RSOption? = nil) {
        guard newId.isNotEmpty else {
            log(message: "newId can not be empty", logLevel: .warning)
            return
        }
        let message = AliasMessage(newId: newId, option: option)
            .applyAlias(newId: newId, client: self)
            .applyRawEventData()
        setAlias(newId)
        setUserId(newId)
        process(message: message)
    }
    
    internal func _identify(_ userId: String, traits: IdentifyTraits? = nil, option: RSOption? = nil) {
        guard userId.isNotEmpty else {
            log(message: "userId can not be empty", logLevel: .warning)
            return
        }
        let message = IdentifyMessage(userId: userId, traits: traits, option: option)
            .applyRawEventData()
        setTraits(traits)
        setUserId(userId)
        process(message: message)
    }
}

// MARK: - System Modifiers

extension RSClient {
    /**
     Returns the anonymousId currently in use.
     */
    @objc
    public var anonymousId: String? {
        if let anonymousIdPlugin = self.find(pluginType: RSAnonymousIdPlugin.self) {
            return anonymousIdPlugin.anonymousId
        }
        return nil
    }
    
    /**
     Returns the userId that was specified in the last identify call.
     */
    @objc
    public var userId: String? {
        if let userIdPlugin = self.find(pluginType: RSUserIdPlugin.self) {
            return userIdPlugin.userId
        }
        return nil
    }
    
    /**
     Returns the context that were specified in the last call.
     */
    @objc
    public var context: MessageContext? {
        if let contextPlugin = self.find(pluginType: RSContextPlugin.self) {
            return contextPlugin.context
        }
        return nil
    }
    
    /**
     Returns the traits that were specified in the last identify call.
     */
    @objc
    public var traits: MessageTraits? {
        if let contextPlugin = self.find(pluginType: RSContextPlugin.self) {
            return contextPlugin.traits
        }
        return nil
    }
    
    /**
     API for flush any queued events. This command will also be sent to each destination present in the system.
     */
    @objc
    public func flush() {
        apply { plugin in
            if let p = plugin as? RSEventPlugin {
                p.flush()
            }
        }
    }
    
    /**
     API for reset current slate.  Traits, UserID's, anonymousId, etc are all cleared or reset.  This command will also be sent to each destination present in the system.
     */
    @objc
    public func reset() {
        apply { plugin in
            if let p = plugin as? RSEventPlugin {
                p.reset()
            }
        }
    }
    
    /**
     Returns the version ("BREAKING.FEATURE.FIX" format) of this library in use.
     */
    @objc
    public var version: String {
        return RSVersion
    }
    
    /**
     Returns the config set by developer while initialisation.
     */
    @objc
    public var configuration: RSConfig? {
        return config
    }
}

extension RSClient {
    func apply(closure: (RSPlugin) -> Void) {
        controller.apply(closure)
    }
    
    /**
     API for adding a new plugin to the currently loaded set.
     - Parameters:
        - plugin: The plugin to be added.
     - Returns: Returns the name of the supplied plugin.
     */
    @discardableResult
    public func add(plugin: RSPlugin) -> RSPlugin {
        plugin.configure(client: self)
        controller.add(plugin: plugin)
        return plugin
    }
    
    func remove(plugin: RSPlugin) {
        controller.remove(plugin: plugin)
    }
    
    func find<T: RSPlugin>(pluginType: T.Type) -> T? {
        return controller.find(pluginType: pluginType)
    }
}

extension RSClient {
    func process(message: RSMessage) {
        switch message {
        case let e as TrackMessage:
            controller.process(incomingEvent: e)
        case let e as IdentifyMessage:
            controller.process(incomingEvent: e)
        case let e as ScreenMessage:
            controller.process(incomingEvent: e)
        case let e as GroupMessage:
            controller.process(incomingEvent: e)
        case let e as AliasMessage:
            controller.process(incomingEvent: e)
        default:
            break
        }
    }
}
