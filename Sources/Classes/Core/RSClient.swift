//
//  RSClient.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public class RSClient {
    let config: Config
    let controller: Controller

     /**
      Initialize this instance of RSClient with a given configuration setup.
      - Parameters:
      - config: The configuration to use
      # Example #
      ```
      let config: Config = Config(writeKey: WRITE_KEY)
      .dataPlaneURL(DATA_PLANE_URL)
      
      RSClient.sharedInstance().configure(with: config)
      ```
      */
    
    public init(
        config: Config,
        database: Database? = nil,
        storage: Storage? = nil,
        userDefaults: UserDefaults? = nil,
        apiClient: APIClient? = nil,
        sourceConfigDownloader: SourceConfigDownloaderType? = nil,
        dataUploader: DataUploaderType? = nil,
        logger: LoggerProtocol? = nil
    ) {
        self.config = config
        self.controller = Controller(
            config: config,
            database: database,
            storage: storage,
            userDefaults: userDefaults,
            sourceConfigDownloader: sourceConfigDownloader,
            dataUploader: dataUploader,
            apiClient: apiClient,
            logger: logger
        )
        addPlugins()
    }
}
    
extension RSClient {
    public func addPlugin(_ plugin: Plugin) {
        plugin.client = self
        controller.addPlugin(plugin)
    }
    
    public func removePlugin(_ plugin: Plugin) {
        controller.removePlugin(plugin)
    }
    
    public func getPluginList(by pluginType: PluginType) -> [Plugin]? {
        return controller.getPluginList(by: pluginType)
    }
    
    public func getPlugin<T: Plugin>(type: T.Type) -> T? {
        return controller.getPlugin(type: type)
    }
    
    public func associatePlugins(_ handler: (Plugin) -> Void) {
        controller.associatePlugins(handler)
    }
}

extension RSClient {
    /**
     API for track your event
     - Parameters:
        - eventName: Name of the event you want to track
        - properties: Properties you want to pass with the track call
        - option: MessageOptions related to this track call
     # Example #
     ```
     RSClient.sharedInstance().track("simple_track_with_props", properties: ["key_1": "value_1", "key_2": "value_2"], option: MessageOption())
     ```
     */
    
    public func track(_ eventName: String, properties: TrackProperties, option: MessageOption) {
        controller.track(eventName, properties: properties, option: option)
    }
    
    public func track(_ eventName: String, properties: TrackProperties) {
        controller.track(eventName, properties: properties, option: nil)
    }
    
    public func track(_ eventName: String, option: MessageOption) {
        controller.track(eventName, properties: nil, option: option)
    }
    
    public func track(_ eventName: String) {
        controller.track(eventName, properties: nil, option: nil)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - userId: User id of your user
        - traits: Other user properties
        - option: IdentifyOptions related to this identify call
     # Example #
     ```
     RSClient.sharedInstance().identify("user_id", traits: ["email": "abc@def.com"], option: IdentifyOption())
     ```
     */
    
    public func identify(_ userId: String, traits: IdentifyTraits, option: IdentifyOptionType) {
        controller.identify(userId, traits: traits, option: option)
    }
    
    public func identify(_ userId: String, traits: IdentifyTraits) {
        controller.identify(userId, traits: traits, option: nil)
    }
    
    public func identify(_ userId: String, option: IdentifyOptionType) {
        controller.identify(userId, traits: nil, option: option)
    }
    
    public func identify(_ userId: String) {
        controller.identify(userId, traits: nil, option: nil)
    }
    
    /**
     API for record screen
     - Parameters:
        - screenName: Name of the screen
        - properties: Properties you want to pass with the screen call
        - option: MessageOptions related to this screen call
     # Example #
     ```
     RSClient.sharedInstance().screen("ViewController", properties: ["key_1": "value_1", "key_2": "value_2"], option: MessageOption())
     ```
     */
    
    public func screen(_ screenName: String, properties: ScreenProperties, option: MessageOption) {
        controller.screen(screenName, category: nil, properties: properties, option: option)
    }
    
    public func screen(_ screenName: String, properties: ScreenProperties) {
        controller.screen(screenName, category: nil, properties: properties, option: nil)
    }
    
    public func screen(_ screenName: String, option: MessageOption) {
        controller.screen(screenName, category: nil, properties: nil, option: option)
    }
    
    public func screen(_ screenName: String, category: String, properties: ScreenProperties, option: MessageOption) {
        controller.screen(screenName, category: category, properties: properties, option: option)
    }

    public func screen(_ screenName: String, category: String, properties: ScreenProperties) {
        controller.screen(screenName, category: category, properties: properties, option: nil)
    }
    
    public func screen(_ screenName: String, category: String, option: MessageOption) {
        controller.screen(screenName, category: category, properties: nil, option: option)
    }

    public func screen(_ screenName: String, category: String) {
        controller.screen(screenName, category: category, properties: nil, option: nil)
    }

    public func screen(_ screenName: String) {
        controller.screen(screenName, category: nil, properties: nil, option: nil)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - groupId: Group ID you want your user to attach to
        - traits: Traits of the group
        - option: MessageOptions related to this group call
     # Example #
     ```
     RSClient.sharedInstance().group("sample_group_id", traits: ["key_1": "value_1", "key_2": "value_2"], option: MessageOption())
     ```
     */
    
    public func group(_ groupId: String, traits: GroupTraits, option: MessageOption) {
        controller.group(groupId, traits: traits, option: option)
    }
    
    public func group(_ groupId: String, traits: GroupTraits) {
        controller.group(groupId, traits: traits, option: nil)
    }
    
    public func group(_ groupId: String, option: MessageOption) {
        controller.group(groupId, traits: nil, option: option)
    }
    
    public func group(_ groupId: String) {
        controller.group(groupId, traits: nil, option: nil)
    }
    
    /**
     API for add the user to a group
     - Parameters:
        - newId: New userId for the user
        - option: MessageOptions related to this alias call
     # Example #
     ```
     RSClient.sharedInstance().alias("user_id", option: MessageOption())
     ```
     */
    
    public func alias(_ newId: String, option: MessageOption) {
        controller.alias(newId, option: option)
    }
    
    public func alias(_ newId: String) {
        controller.alias(newId, option: nil)
    }
}

extension RSClient {
    /**
     Returns the anonymousId currently in use.
     */
    public var anonymousId: String? {
        controller.anonymousId
    }
    
    /**
     Returns the userId that was specified in the last identify call.
     */
    public var userId: String? {
        controller.userId
    }
    
    /**
     Returns the context that were specified in the last call.
     */
    public var context: Context? {
        controller.context
    }
    
    /**
     Returns the traits that were specified in the last identify call.
     */
    public var traits: IdentifyTraits? {
        controller.traits
    }
    
    /**
     Returns the version ("BREAKING.FEATURE.FIX" format) of this library in use.
     */
    public var version: String {
        return RSVersion
    }
    
    /**
     Returns the config set by developer while initialisation.
     */
    public var configuration: Config? {
        controller.config
    }
    
    /**
     Returns id of an active session.
     */
    public var sessionId: String? {
        controller.sessionId
    }
}

extension RSClient {
    /**
     API for flush any queued events. This command will also be sent to each destination present in the system.
     */
    public func flush() {
        controller.flush()
    }
    
    /**
     API for reset current slate.  Traits, UserID's, anonymousId, etc are all cleared or reset.  This command will also be sent to each destination present in the system.
     */
    public func reset(and refreshAnonymousId: Bool) {
        controller.reset(and: refreshAnonymousId)
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
    public func setAnonymousId(_ anonymousId: String) {
        controller.setAnonymousId(anonymousId)
    }

    /**
     API for setting enable/disable sending the events across all the event calls made using the SDK to the specified destinations.
     - Parameters:
        - option: Options related to every API call
     # Example #
     ```
     let defaultOption = Option()
     defaultOption.putIntegration("Amplitude", isEnabled: true)
     
     RSClient.sharedInstance().setOption(defaultOption)
     ```
     */
    public func setOption(_ option: Option) {
        controller.setOption(option)
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
    public func setDeviceToken(_ token: String) {
        controller.setDeviceToken(token)
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
    public func setAdvertisingId(_ advertisingId: String) {
        controller.setAdvertisingId(advertisingId)
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
    public func setAppTrackingConsent(_ appTrackingConsent: AppTrackingConsent) {
        controller.setAppTrackingConsent(appTrackingConsent)
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
    public func setOptOutStatus(_ status: Bool) {
        controller.setOptOutStatus(status)
    }
}

extension RSClient {
    private func addPlugins() {
        addPlugin(ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueuePlugin".queueLabel())))
        addPlugin(IntegrationPlugin())
        addPlugin(UserSessionPlugin())
        addPlugin(ContextPlugin())
        addPlugin(StoragePlugin())
    }
}
