//
//  RSClient.swift
//  RudderStack
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

// swiftlint:disable file_length
@objc
open class RSClient: NSObject {
    static let shared = RSClient()

    let controller: RSController
    let sessionStorage: RSSessionStorage
    let databaseManager: RSDatabaseManager
    
    var userDefaults: RSUserDefaults?
    var config: RSConfig?
    var serverConfig: RSServerConfig? {
        didSet {
            if let serverConfig = serverConfig, let config = config {
                let dataPlaneUrls = RSUtils.getDataPlaneUrls(from: serverConfig, and: config)
                sessionStorage.write(.dataPlaneUrl, value: dataPlaneUrls?.first)
            }
        }
    }
    var serviceManager: RSServiceType?
    var downloadServerConfig: RSDownloadServerConfig?
    var userInfo: RSUserInfo? {
        let userId: String? = userDefaults?.read(.userId)
        let traits: JSON? = userDefaults?.read(.traits)
        var anonymousId: String? = userDefaults?.read(.anonymousId)
        if anonymousId == nil {
            anonymousId = RSUtils.getUniqueId()
            userDefaults?.write(.anonymousId, value: anonymousId)
        }
        return RSUserInfo(anonymousId: anonymousId, userId: userId, traits: traits)
    }
    
    @RSAtomic var isServerConfigCached = false

    private override init() {
        controller = RSController()
        sessionStorage = RSSessionStorage()
        databaseManager = RSDatabaseManager()
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
        // Config can be set only one time per session.
        guard self.config == nil else { return }
        self.config = config
        self.userDefaults = config.userDefaults
        self.serviceManager = RSServiceManager(userDefaults: config.userDefaults, config: config, sessionStorage: sessionStorage)
        self.downloadServerConfig = config.downloadServerConfig != nil ? config.downloadServerConfig : RSDownloadServerConfigImpl(serviceManager: serviceManager)
        self.serverConfig = config.userDefaults.read(.serverConfig)
        self.isServerConfigCached = serverConfig != nil
        Logger.logLevel = config.logLevel
        if config.writeKey.isEmpty {
            Logger.logError("Invalid writeKey: Provided writeKey is empty")
        }
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
    public func track(_ eventName: String, option: RSOption) {
        _track(eventName, properties: nil, option: option)
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
    public func identify(_ userId: String, option: RSOption) {
        _identify(userId, traits: nil, option: option)
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
    public func screen(_ screenName: String, properties: ScreenProperties, option: RSOption) {
        _screen(screenName, category: nil, properties: properties, option: option)
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
    public func screen(_ screenName: String, option: RSOption) {
        _screen(screenName, category: nil, properties: nil, option: option)
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
    public func group(_ groupId: String, option: RSOption) {
        _group(groupId, traits: nil, option: option)
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
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOutAndEventDrop, logLevel: .debug)
            return
        }
        guard eventName.isNotEmpty else {
            Logger.log(message: "eventName can not be empty", logLevel: .warning)
            return
        }
        let message = TrackMessage(event: eventName, properties: properties, option: option)
        process(incomingMessage: message)
    }
    
    internal func _screen(_ screenName: String, category: String? = nil, properties: ScreenProperties? = nil, option: RSOption? = nil) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOutAndEventDrop, logLevel: .debug)
            return
        }
        guard screenName.isNotEmpty else {
            Logger.log(message: "screenName can not be empty", logLevel: .warning)
            return
        }
        var screenProperties = ScreenProperties()
        if let properties = properties {
            screenProperties = properties
        }
        screenProperties["name"] = screenName
        let message = ScreenMessage(title: screenName, category: category, properties: screenProperties, option: option)
        process(incomingMessage: message)
    }
    
    internal func _group(_ groupId: String, traits: [String: String]? = nil, option: RSOption? = nil) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOutAndEventDrop, logLevel: .debug)
            return
        }
        guard groupId.isNotEmpty else {
            Logger.log(message: "groupId can not be empty", logLevel: .warning)
            return
        }
        let message = GroupMessage(groupId: groupId, traits: traits, option: option)
        process(incomingMessage: message)
    }
    
    internal func _alias(_ newId: String, option: RSOption? = nil) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOutAndEventDrop, logLevel: .debug)
            return
        }
        guard newId.isNotEmpty else {
            Logger.log(message: "newId can not be empty", logLevel: .warning)
            return
        }
        let previousId: String? = userDefaults?.read(.userId)
        userDefaults?.write(.userId, value: newId)
        var dict: [String: Any] = ["id": newId]
        if let json: JSON = userDefaults?.read(.traits), let traits = json.dictionaryValue {
            dict.merge(traits) { (_, new) in new }
        }
        userDefaults?.write(.traits, value: try? JSON(dict))
        let message = AliasMessage(newId: newId, previousId: previousId, option: option)
        process(incomingMessage: message)
    }
    
    internal func _identify(_ userId: String, traits: IdentifyTraits? = nil, option: RSOption? = nil) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOutAndEventDrop, logLevel: .debug)
            return
        }
        guard userId.isNotEmpty else {
            Logger.log(message: "userId can not be empty", logLevel: .warning)
            return
        }
        userDefaults?.write(.userId, value: userId)
        
        if let traits = traits {
            userDefaults?.write(.traits, value: try? JSON(traits))
        }
        
        if let externalIds = option?.externalIds {
            userDefaults?.write(.externalId, value: try? JSON(externalIds))
        }
        let message = IdentifyMessage(userId: userId, traits: traits, option: option)
        process(incomingMessage: message)
    }
}

// MARK: - System Modifiers

extension RSClient {
    /**
     Returns the anonymousId currently in use.
     */
    @objc
    public var anonymousId: String? {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return nil
        }
        return userDefaults?.read(.anonymousId)
    }
    
    /**
     Returns the userId that was specified in the last identify call.
     */
    @objc
    public var userId: String? {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return nil
        }
        return userDefaults?.read(.userId)
    }
    
    /**
     Returns the context that were specified in the last call.
     */
    @objc
    public var context: RSContext? {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return nil
        }
        if let currentContext: RSContext = sessionStorage.read(.context) {
            return currentContext
        }
        return RSContext(userDefaults: userDefaults)
    }
    
    /**
     Returns the traits that were specified in the last identify call.
     */
    @objc
    public var traits: IdentifyTraits? {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return nil
        }
        let traitsJSON: JSON? = RSContext.traits(userDefaults: userDefaults)
        return traitsJSON?.dictionaryValue
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
    public func reset(and refreshAnonymousId: Bool) {
        if refreshAnonymousId {
            userDefaults?.write(.anonymousId, value: RSUtils.getUniqueId())
        }
        reset()
    }
    
    /**
     API for reset current slate.  Traits, UserID's, anonymousId, etc are all cleared or reset.  This command will also be sent to each destination present in the system.
     */
    @objc
    public func reset() {
        userDefaults?.reset()
        sessionStorage.reset()
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
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return nil
        }
        return config
    }
    
    /**
     Returns id of an active session.
     */
    @objc
    public var sessionId: String? {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return nil
        }
        if let userSessionPlugin = self.find(pluginType: RSUserSessionPlugin.self), let sessionId = userSessionPlugin.sessionId {
            return "\(sessionId)"
        }
        return nil
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
    func process(incomingMessage: RSMessage) {
        let message = incomingMessage.applyRawEventData(userInfo: userInfo)
        process(message: message)
    }
    
    func process(message: RSMessage) {
        if let serverConfig = serverConfig, !serverConfig.enabled {
            Logger.logDebug("Source is disabled in your dashboard. Hence event is dropped.")
            return
        }
        
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

extension RSClient {
    /**
     API for setting unique identifier of every call.
     - Parameters:
        - anonymousId: Unique identifier of every event
     # Example #
     ```
     RSClient.sharedInstance().setAnonymousId("sample_anonymous_id")
     ```
     */
    @objc
    public func setAnonymousId(_ anonymousId: String) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return
        }
        guard anonymousId.isNotEmpty else {
            Logger.log(message: "anonymousId can not be empty", logLevel: .warning)
            return
        }
        userDefaults?.write(.anonymousId, value: anonymousId)
    }

    /**
     API for setting enable/disable sending the events across all the event calls made using the SDK to the specified destinations.
     - Parameters:
        - option: Options related to every API call
     # Example #
     ```
     let defaultOption = RSOption()
     defaultOption.putIntegration("Amplitude", isEnabled: true)
     
     RSClient.sharedInstance().setOption(defaultOption)
     ```
     */
    @objc
    public func setOption(_ option: RSOption) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return
        }
        sessionStorage.write(.option, value: option)
    }

    /**
     API for setting token under context.device.token.
     - Parameters:
        - token: Token of the device
     # Example #
     ```
     RSClient.sharedInstance().setDeviceToken("sample_device_token")
     ```
     */
    @objc
    public func setDeviceToken(_ token: String) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return
        }
        guard token.isNotEmpty else {
            Logger.log(message: "token can not be empty", logLevel: .warning)
            return
        }
        sessionStorage.write(.deviceToken, value: token)
    }

    /**
     API for setting identifier under context.device.advertisingId.
     - Parameters:
        - advertisingId: IDFA value
     # Example #
     ```
     RSClient.sharedInstance().setAdvertisingId("sample_advertising_id")
     ```
     */
    @objc
    public func setAdvertisingId(_ advertisingId: String) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return
        }
        guard advertisingId.isNotEmpty else {
            Logger.log(message: "advertisingId can not be empty", logLevel: .warning)
            return
        }
        if advertisingId != "00000000-0000-0000-0000-000000000000" {
            sessionStorage.write(.advertisingId, value: advertisingId)
        }
    }

    /**
     API for app tracking consent management.
     - Parameters:
        - appTrackingConsent: App tracking consent
     # Example #
     ```
     RSClient.sharedInstance().setAppTrackingConsent(.authorize)
     ```
     */
    @objc
    public func setAppTrackingConsent(_ appTrackingConsent: RSAppTrackingConsent) {
        if let optOutStatus: Bool = userDefaults?.read(.optStatus), optOutStatus {
            Logger.log(message: LogMessages.optOut, logLevel: .debug)
            return
        }
        sessionStorage.write(.appTrackingConsent, value: appTrackingConsent)
    }
    
    /**
     API for enable or disable tracking user activities.
     - Parameters:
        - status: Enable or disable tracking
     # Example #
     ```
     RSClient.sharedInstance().setOptOutStatus(false)
     ```
     */
    @objc
    public func setOptOutStatus(_ status: Bool) {
        userDefaults?.write(.optStatus, value: status)
        Logger.log(message: "User has been Opted \(status ? "out" : "in")", logLevel: .debug)
    }
}
