//
//  RudderClient.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/12/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc
open class RudderClient: NSObject {
    @objc
    public static func initialize(config: RSConfig, instanceName: String = DEFAULT_INSTANCE_NAME) -> RSClient {
        guard !CoreRegistry.isRegistered(instanceName: instanceName) else {
            return CoreRegistry.default
        }
        let instance = RSClient(instanceName: instanceName, config: config)
        CoreRegistry.register(instance, name: instanceName)
        return instance
    }
    
    @objc
    public static func sdkInstance(named name: String) -> RSClient {
        CoreRegistry.instance(named: name)
    }
    
    /**
     API for track your event
     - Parameters:
        - eventName: Name of the event you want to track
        - properties: Properties you want to pass with the track call
        - option: Options related to this track call
     # Example #
     ```
     RudderClient.track("simple_track_with_props", properties: ["key_1": "value_1", "key_2": "value_2"], option: RSOption())
     ```
     */
    @objc
    public static func track(_ eventName: String, properties: TrackProperties, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _track(eventName, properties: properties, option: option, for: instance)
    }
    
    @objc
    public static func track(_ eventName: String, properties: TrackProperties, for instance: RSClient = CoreRegistry.default) {
        _track(eventName, properties: properties, option: nil, for: instance)
    }
    
    @objc
    public static func track(_ eventName: String, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _track(eventName, properties: nil, option: option, for: instance)
    }
    
    @objc
    public static func track(_ eventName: String, for instance: RSClient = CoreRegistry.default) {
        _track(eventName, properties: nil, option: nil, for: instance)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - userId: User id of your user
        - traits: Other user properties
        - option: Options related to this identify call
     # Example #
     ```
     RudderClient.identify("user_id", traits: ["email": "abc@def.com"], option: RSOption())
     ```
     */
    
    @objc
    public static func identify(_ userId: String, traits: IdentifyTraits, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _identify(userId, traits: traits, option: option, for: instance)
    }
    
    @objc
    public static func identify(_ userId: String, traits: IdentifyTraits, for instance: RSClient = CoreRegistry.default) {
        _identify(userId, traits: traits, option: nil, for: instance)
    }
    
    @objc
    public static func identify(_ userId: String, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _identify(userId, traits: nil, option: option, for: instance)
    }
    
    @objc
    public static func identify(_ userId: String, for instance: RSClient = CoreRegistry.default) {
        _identify(userId, traits: nil, option: nil, for: instance)
    }
    
    /**
     API for record screen
     - Parameters:
        - screenName: Name of the screen
        - properties: Properties you want to pass with the screen call
        - option: Options related to this screen call
     # Example #
     ```
     RudderClient.screen("ViewController", properties: ["key_1": "value_1", "key_2": "value_2"], option: RSOption())
     ```
     */
    @objc
    public static func screen(_ screenName: String, category: String, properties: ScreenProperties, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: category, properties: properties, option: option, for: instance)
    }
    
    @objc
    public static func screen(_ screenName: String, category: String, properties: ScreenProperties, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: category, properties: properties, option: nil, for: instance)
    }
    
    @objc
    public static func screen(_ screenName: String, properties: ScreenProperties, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: nil, properties: properties, option: option, for: instance)
    }
    
    @objc
    public static func screen(_ screenName: String, properties: ScreenProperties, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: nil, properties: properties, option: nil, for: instance)
    }
    
    @objc
    public static func screen(_ screenName: String, category: String, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: category, properties: nil, option: nil, for: instance)
    }
    
    @objc
    public static func screen(_ screenName: String, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: nil, properties: nil, option: option, for: instance)
    }
    
    @objc
    public static func screen(_ screenName: String, for instance: RSClient = CoreRegistry.default) {
        _screen(screenName, category: nil, properties: nil, option: nil, for: instance)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - groupId: Group ID you want your user to attach to
        - traits: Traits of the group
        - option: Options related to this group call
     # Example #
     ```
     RudderClient.group("sample_group_id", traits: ["key_1": "value_1", "key_2": "value_2"], option: RSOption())
     ```
     */
    @objc
    public static func group(_ groupId: String, traits: GroupTraits, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _group(groupId, traits: traits, option: option, for: instance)
    }
    
    @objc
    public static func group(_ groupId: String, traits: GroupTraits, for instance: RSClient = CoreRegistry.default) {
        _group(groupId, traits: traits, option: nil, for: instance)
    }
    
    @objc
    public static func group(_ groupId: String, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _group(groupId, traits: nil, option: option, for: instance)
    }
    
    @objc
    public static func group(_ groupId: String, for instance: RSClient = CoreRegistry.default) {
        _group(groupId, traits: nil, option: nil, for: instance)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - newId: New userId for the user
        - option: Options related to this alias call
     # Example #
     ```
     RudderClient.alias("user_id", option: RSOption())
     ```
     */
    
    @objc
    public static func alias(_ newId: String, option: RSOption, for instance: RSClient = CoreRegistry.default) {
        _alias(newId, option: option, for: instance)
    }
    
    @objc
    public static func alias(_ newId: String, for instance: RSClient = CoreRegistry.default) {
        _alias(newId, option: nil, for: instance)
    }
}

extension RudderClient {
    
    static func _track(_ eventName: String, properties: TrackProperties? = nil, option: RSOption? = nil, for instance: RSClient) {
        instance._track(eventName, properties: properties, option: option)
    }
    
    static func _screen(_ screenName: String, category: String? = nil, properties: ScreenProperties? = nil, option: RSOption? = nil, for instance: RSClient) {
        instance._screen(screenName, category: category, properties: properties, option: option)
    }
    
    static func _group(_ groupId: String, traits: [String: String]? = nil, option: RSOption? = nil, for instance: RSClient) {
        instance._group(groupId, traits: traits, option: option)
    }
    
    static func _alias(_ newId: String, option: RSOption? = nil, for instance: RSClient) {
        instance._alias(newId, option: option)
    }
    
    static func _identify(_ userId: String, traits: IdentifyTraits? = nil, option: RSOption? = nil, for instance: RSClient) {
        instance._identify(userId, traits: traits, option: option)
    }
}

extension RudderClient {
    /**
     Returns the anonymousId currently in use.
     */
    @objc
    public static func anonymousId(for instance: RSClient = CoreRegistry.default) -> String? {
        return instance.anonymousId
    }
    
    /**
     Returns the userId that was specified in the last identify call.
     */
    @objc
    public static func userId(for instance: RSClient = CoreRegistry.default) -> String? {
        return instance.userId
    }
    
    /**
     Returns the context that were specified in the last call.
     */
    @objc
    public static func context(for instance: RSClient = CoreRegistry.default) -> RSContext? {
        return instance.context
    }
    
    /**
     Returns the traits that were specified in the last identify call.
     */
    @objc
    public static func traits(for instance: RSClient = CoreRegistry.default) -> IdentifyTraits? {
        return instance.traits
    }
    
    /**
     API for flush any queued events. This command will also be sent to each destination present in the system.
     */
    @objc
    public static func flush(for instance: RSClient = CoreRegistry.default) {
        instance.flush()
    }
    
    /**
     API for reset current slate.  Traits, UserID's, anonymousId, etc are all cleared or reset.  This command will also be sent to each destination present in the system.
     */
    @objc
    public static func reset(and refreshAnonymousId: Bool, for instance: RSClient = CoreRegistry.default) {
        instance.reset(and: refreshAnonymousId)
    }
    
    /**
     API for reset current slate.  Traits, UserID's, anonymousId, etc are all cleared or reset.  This command will also be sent to each destination present in the system.
     */
    @objc
    public static func reset(for instance: RSClient = CoreRegistry.default) {
        instance.reset()
    }
    
    /**
     Returns the version ("BREAKING.FEATURE.FIX" format) of this library in use.
     */
    @objc
    public static var sdkVersion: String {
        return RSVersion
    }
    
    /**
     Returns the config set by developer while initialisation.
     */
    @objc
    public static func configuration(for instance: RSClient = CoreRegistry.default) -> RSConfig? {
        return instance.configuration
    }
    
    /**
     Returns id of an active session.
     */
    @objc
    public static func sessionId(for instance: RSClient = CoreRegistry.default) -> String? {
        return instance.sessionId
    }
}

extension RudderClient {
    /**
     API for setting unique identifier of every call.
     - Parameters:
        - anonymousId: Unique identifier of every event
     # Example #
     ```
     RudderClient.setAnonymousId("sample_anonymous_id")
     ```
     */
    @objc
    public static func setAnonymousId(_ anonymousId: String, for instance: RSClient = CoreRegistry.default) {
        instance.setAnonymousId(anonymousId)
    }
    
    /**
     API for setting enable/disable sending the events across all the event calls made using the SDK to the specified destinations.
     - Parameters:
        - option: Options related to every API call
     # Example #
     ```
     let defaultOption = RSOption()
     defaultOption.putIntegration("Amplitude", isEnabled: true)
     
     RudderClient.setOption(defaultOption)
     ```
     */
    @objc
    public static func setOption(_ option: RSOption, for instance: RSClient = CoreRegistry.default) {
        instance.setOption(option)
    }
    
    /**
     API for setting token under context.device.token.
     - Parameters:
        - token: Token of the device
     # Example #
     ```
     RudderClient.setDeviceToken("sample_device_token")
     ```
     */
    @objc
    public static func setDeviceToken(_ token: String, for instance: RSClient = CoreRegistry.default) {
        instance.setDeviceToken(token)
    }
    
    /**
     API for setting identifier under context.device.advertisingId.
     - Parameters:
        - advertisingId: IDFA value
     # Example #
     ```
     RudderClient.setAdvertisingId("sample_advertising_id")
     ```
     */
    @objc
    public static func setAdvertisingId(_ advertisingId: String, for instance: RSClient = CoreRegistry.default) {
        instance.setAdvertisingId(advertisingId)
    }
    
    /**
     API for app tracking consent management.
     - Parameters:
        - appTrackingConsent: App tracking consent
     # Example #
     ```
     RudderClient.setAppTrackingConsent(.authorize)
     ```
     */
    @objc
    public static func setAppTrackingConsent(_ appTrackingConsent: RSAppTrackingConsent, for instance: RSClient = CoreRegistry.default) {
        instance.setAppTrackingConsent(appTrackingConsent)
    }
    
    /**
     API for enable or disable tracking user activities.
     - Parameters:
        - status: Enable or disable tracking
     # Example #
     ```
     RudderClient.setOptOutStatus(false)
     ```
     */
    @objc
    public static func setOptOutStatus(_ status: Bool, for instance: RSClient = CoreRegistry.default) {
        instance.setOptOutStatus(status)
    }
}
