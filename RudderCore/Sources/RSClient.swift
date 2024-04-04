//
//  RSClient.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

/// An entry point to RudderStack SDK.
/// 
/// Initialize the default instance of RudderStack SDK.
/// 
/// ```swift
///  if let configuration: Configuration = Configuration(
///      writeKey: "<write key>",
///      dataPlaneURL: "<data plane url>"
///  ) {
///      RSClient.initialize(
///          with: configuration
///      )
///  }
/// ```
/// 
public class RSClient: RudderProtocol {
    
    /// Configuration of RudderStack SDK.
    public var configuration: Configuration {
        core.configuration
    }
    
    /// A UserDefaultsWorker instance.
    public var userDefaultsWorker: UserDefaultsWorkerProtocol {
        core.userDefaultsWorker
    }
    
    /// StorageWorker instance.
    public var storageWorker: StorageWorkerProtocol {
        core.storageWorker
    }
    
    /// SessionStorage instance.
    public var sessionStorage: SessionStorageProtocol {
        core.sessionStorage
    }
    
    /// Log information.
    public var logger: Logger {
        core.logger
    }
    
    /// Given instance name.
    public var instanceName: String {
        core.instanceName
    }
    
    private let core: RudderCore

    /// Creates a `RSClient` instance.
    /// - Parameters:
    ///   - configuration: The SDK configuration.
    ///   - instanceName: The core instance name. This value will be used for data persistency and differentiate between instances.
    ///   - database: The developer-choice `SQLite` database. Can be used `SQLCipher` as well.
    ///   - storage: The developer-choice storage. Can be used file system and any other storage implementation.
    ///   - userDefaults: The developer-choice `UserDefaults` implementation.
    ///   - apiClient: The developer-choice networking client. Can be used `Alamofire`, `Moya`, etc....
    ///   - sourceConfigDownloader: The developer-choice source config download implementation.
    ///   - dataUploader: The developer-choice source upload data(events) to server implementation.
    ///   - storageMigrator: The developer-choice storage migration implementation, if any.
    ///   - logger: The developer-choice logger.
    required init(
        configuration: Configuration,
        instanceName: String,
        database: Database? = nil,
        storage: Storage? = nil,
        userDefaults: UserDefaults? = nil,
        apiClient: APIClient? = nil,
        sourceConfigDownloader: SourceConfigDownloaderType? = nil,
        dataUploader: DataUploaderType? = nil,
        storageMigrator: StorageMigrator? = nil
    ) {
        core = RudderCore(
            configuration: configuration,
            instanceName: instanceName,
            database: database,
            storage: storage,
            userDefaults: userDefaults,
            sourceConfigDownloader: sourceConfigDownloader,
            dataUploader: dataUploader,
            apiClient: apiClient
        )
        addPlugins()
        RudderRegistry.register(self, name: instanceName)
    }
    
    /// Initialize the RudderStack SDK.
    ///
    /// Initialize the default instance of RudderStack SDK.
    ///
    /// ```swift
    ///  if let configuration: Configuration = Configuration(
    ///      writeKey: "<write key>",
    ///      dataPlaneURL: "<data plane url>"
    ///  ) {
    ///      RSClient.initialize(
    ///          with: configuration
    ///      )
    ///  }
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: The SDK configuration.
    ///   - instanceName: The core instance name. This value will be used for data persistency and differentiate between instances.
    ///   - database: The developer-choice `SQLite` database implementation, if any.
    ///   - storage: The developer-choice storage implementation, if any.
    ///   - userDefaults: The developer-choice `UserDefaults` implementation, if any.
    ///   - apiClient: The developer-choice networking client implementation, if any.
    ///   - sourceConfigDownloader: The developer-choice source config download implementation, if any.
    ///   - dataUploader: The developer-choice source upload data(events) to server implementation, if any.
    ///   - logger: The developer-choice logger, if any.
    ///   - storageMigrator: The developer-choice storage migration implementation, if any.
    /// - Returns: An instance of `RSClient`.
    ///
    @discardableResult
    public static func initialize(
        with configuration: Configuration,
        instanceName: String = RudderRegistry.defaultInstanceName,
        database: Database? = nil,
        storage: Storage? = nil,
        userDefaults: UserDefaults? = nil,
        apiClient: APIClient? = nil,
        sourceConfigDownloader: SourceConfigDownloaderType? = nil,
        dataUploader: DataUploaderType? = nil
    ) -> RSClient {
        if instanceName.correctified == RudderRegistry.defaultInstanceName, RudderRegistry.isRegistered(instanceName: instanceName.correctified),
           let instance = RudderRegistry.default {
                return instance
        }
        let instance = self.init(
            configuration: configuration,
            instanceName: instanceName.correctified,
            database: database,
            storage: storage,
            userDefaults: userDefaults,
            apiClient: apiClient,
            sourceConfigDownloader: sourceConfigDownloader,
            dataUploader: dataUploader
        )
        return instance
    }
}

extension RSClient {
    
    /// Returns the RudderStack instance for the given name.
    ///
    /// - Parameter name: The name of the instance to get.
    /// - Returns: The instance by the name if exists, otherwise nil.
    public static func instance(named name: String) -> RSClient? {
        RudderRegistry.instance(named: name)
    }
    
    /// Returns the default instance if registered.
    public static var `default`: RSClient? {
        RudderRegistry.default
    }
    
    /// Check if an instance with specific name is registered.
    /// - Parameter instanceName: The name of the instance to check.
    /// - Returns: `true` if an instance with the given name is registered, otherwise `false`.
    public static func isRegistered(instanceName: String) -> Bool {
        return RudderRegistry.isRegistered(instanceName: instanceName)
    }
    
    /// Unregister a instance for the given name.
    /// - Parameter name: The name of the instance to unregister.
    public static func unregisterInstance(named name: String) {
        RudderRegistry.unregisterInstance(named: name)
    }
}
    
extension RSClient {
    
    /// Add a Plugin instance.
    ///
    /// - Parameter plugin: The Plugin instance.
    public func addPlugin(_ plugin: Plugin) {
        plugin.client = self
        core.addPlugin(plugin)
    }
    
    /// Remove a Plugin instance.
    /// - Parameter plugin: The Plugin instance.
    public func removePlugin(_ plugin: Plugin) {
        core.removePlugin(plugin)
    }
    
    /// Retrieve all Plugin instance list.
    ///
    /// - Returns: The list of all Plugins.
    public func getAllPlugins() -> [Plugin]? {
        return core.getAllPlugins()
    }
    
    /// Retrieve all destination Plugin instance list.
    ///
    /// - Returns: The list of Plugins if any.
    public func getDestinationPlugins() -> [DestinationPlugin]? {
        return core.getDestinationPlugins()
    }
    
    /// Retrieve all default Plugin instance list.
    ///
    /// - Returns: The list of default Plugins if any.
    public func getDefaultPlugins() -> [Plugin]? {
        return core.getDefaultPlugins()
    }
        
    /// Retrive a Plugin instance by instance type.
    /// - Parameter type: The Plugin instance type.
    /// - Returns: The instance of Plugin if any.
    public func getPlugin<T: Plugin>(type: T.Type) -> T? {
        return core.getPlugin(type: type)
    }
    
    /// Associate a handler to all the Plugin list.
    ///
    /// - Parameter handler: The closure which takes a Plugin as a parameter.
    public func associatePlugins(_ handler: (Plugin) -> Void) {
        core.associatePlugins(handler)
    }
}

extension RSClient {
    
    /// Record user's activity.
    ///
    /// - Parameters:
    ///   - eventName: The name of the activity.
    ///   - properties: Extra data properties regarding the event, if any.
    ///   - option: Extra event options, if any.
    public func track(_ eventName: String, properties: TrackProperties? = nil, option: MessageOptionType? = nil) {
        core.track(eventName, properties: properties, option: option)
    }
    
    /// Set current user's information
    ///
    /// - Parameters:
    ///   - userId: User's ID.
    ///   - traits: User's additional information, if any.
    ///   - option: Event level option, if any.
    public func identify(_ userId: String, traits: IdentifyTraits? = nil, option: MessageOptionType? = nil) {
        core.identify(userId, traits: traits, option: option)
    }
    
    /// Track a screen with name, category.
    ///
    /// - Parameters:
    ///   - screenName: The name of the screen viewed by an user.
    ///   - category: The category or type of screen, if any.
    ///   - properties: Extra data properties regarding the screen call, if any.
    ///   - option: Extra screen event options, if any.
    public func screen(_ screenName: String, category: String? = nil, properties: ScreenProperties? = nil, option: MessageOptionType? = nil) {
        core.screen(screenName, category: category, properties: properties, option: option)
    }
    
    /// Associate an user to a company or organization.
    ///
    /// - Parameters:
    ///   - groupId: The company's ID.
    ///   - traits: Extra information of the company, if any.
    ///   - option: Event level options, if any.
    public func group(_ groupId: String, traits: GroupTraits? = nil, option: MessageOptionType? = nil) {
        core.group(groupId, traits: traits, option: option)
    }
    
    /// Associate the current user to a new identification.
    ///
    /// - Parameters:
    ///   - groupId: User's new ID.
    ///   - option: Event level options, if any.
    public func alias(_ newId: String, option: MessageOptionType? = nil) {
        core.alias(newId, option: option)
    }
}

extension RSClient {

    /// Returns the anonymousId currently in use.
    public var anonymousId: String? {
        core.anonymousId
    }
    
    /// Returns the userId that was specified in the last identify call.
    public var userId: String? {
        core.userId
    }
    
    /// Returns the context that were specified in the last call.
    public var context: Context? {
        core.context
    }
    
    /// Returns the traits that were specified in the last identify call.
    public var traits: IdentifyTraits? {
        core.traits
    }
    
    /// Returns the version ("BREAKING.FEATURE.FIX" format) of this library in use.
    public var version: String {
        return RSVersion
    }
    
    /// Returns id of an active session.
    public var sessionId: Int? {
        core.sessionId
    }
}

extension RSClient {
    
    /// API for flush any queued events. This command will also be sent to each destination present in the system.
    public func flush() {
        core.flush()
    }
    
    /// Reset current slate.  Traits, UserID's, anonymousId, etc are all cleared or reset.
    /// This command will also be sent to each destination present in the system.
    /// 
    /// - Parameter refreshAnonymousId: Refresh anonymous ID as well.
    public func reset(and refreshAnonymousId: Bool) {
        core.reset(and: refreshAnonymousId)
    }
}

extension RSClient {
    /// API for setting unique identifier of every call.
    ///
    /// - Parameters:
    ///   - anonymousId: Unique identifier of every event
    public func setAnonymousId(_ anonymousId: String) {
        core.setAnonymousId(anonymousId)
    }

    /// API for setting enable/disable sending the events across all the event calls made using the SDK to the specified destinations.
    ///
    /// - Parameters:
    ///   - option: Options related to every API call
    public func setGlobalOption(_ globalOption: GlobalOptionType) {
        core.setGlobalOption(globalOption)
    }

    /// API for setting device token for Push Notifications to the destinations.
    ///
    /// - Parameters:
    ///   - token: Token of the device
    public func setDeviceToken(_ token: String) {
        core.setDeviceToken(token)
    }

    /// API for setting identifier under context.device.advertisingId.
    /// - Parameters:
    ///   - advertisingId: IDFA value
    public func setAdvertisingId(_ advertisingId: String) {
        core.setAdvertisingId(advertisingId)
    }

    /// API for the Data Tracking Consent given by the user of the app.
    ///
    /// - Parameters:
    ///   - appTrackingConsent: The Data Tracking Consent given by the user of the app
    public func setAppTrackingConsent(_ appTrackingConsent: AppTrackingConsent) {
        core.setAppTrackingConsent(appTrackingConsent)
    }
    
    /// API for enable or disable tracking user activities.
    ///
    /// - Parameters:
    ///   - status: Enable or disable tracking.
    public func setOptOutStatus(_ status: Bool) {
        core.setOptOutStatus(status)
    }
}

extension RSClient {
    
    /// Add the default Plugins.
    private func addPlugins() {
        addPlugin(ReplayQueuePlugin(queue: DispatchQueue(label: "replayQueuePlugin".queueLabel(instanceName))))
        addPlugin(IntegrationPlugin())
        addPlugin(UserSessionPlugin())
        addPlugin(ContextPlugin())
        addPlugin(StoragePlugin())
    }
}
