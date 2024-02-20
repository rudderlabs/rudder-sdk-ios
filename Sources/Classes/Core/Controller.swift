//
//  Controller.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class Controller {
    let config: Config
    let database: Database
    let storage: Storage
    let storageWorker: StorageWorker
    let userDefaults: UserDefaultsWorkerType
    let serviceManager: ServiceType
    let sourceConfigDownloader: SourceConfigDownloaderType
    let logger: Logger
    let downloadUploadBlockers: DownloadUploadBlockers = DownloadUploadBlockers()
    let sessionStorage: SessionStorage = SessionStorage()
    var applicationSate: ApplicationState?
    var screenRecording: ScreenRecording?
    var dataUpload: DataUpload?
    var dataUploader: DataUploaderType?
    var sourceConfigDownload: SourceConfigDownload?
    var flushPolicies: [FlushPolicy]
    var pluginList: [PluginType: [Plugin]] = [
        .default: [Plugin](),
        .destination: [Plugin]()
    ]
    var userInfo: UserInfo {
        let userId: String? = userDefaults.read(.userId)
        let traits: JSON? = userDefaults.read(.traits)
        var anonymousId: String? = userDefaults.read(.anonymousId)
        if anonymousId == nil {
            anonymousId = Utility.getUniqueId()
            userDefaults.write(.anonymousId, value: anonymousId)
        }
        return UserInfo(anonymousId: anonymousId, userId: userId, traits: traits)
    }
    @ReadWriteLock var isEnable: Bool = true
    
    init(
        config: Config,
        database: Database? = nil, 
        storage: Storage? = nil,
        userDefaults: UserDefaults? = nil,
        sourceConfigDownloader: SourceConfigDownloaderType? = nil,
        dataUploader: DataUploaderType? = nil,
        apiClient: APIClient? = nil,
        logger: LoggerProtocol? = nil,
        applicationState: ApplicationState? = nil
    ) {
        self.config = config
        self.logger = Logger(logger: logger ?? ConsoleLogger(logLevel: config.logLevel))
        self.database = database ?? DefaultDatabase(path: Device.current.directoryPath, name: "rl_persistence.sqlite")
        self.storage = storage ?? DefaultStorage(
            database: self.database,
            logger: self.logger
        )
        self.storageWorker = DefaultStorageWorker(
            storage: self.storage,
            queue: DispatchQueue(label: "defaultStorageWorker".queueLabel())
        )
        self.storageWorker.open()
        let userDefaultsQueue = DispatchQueue(label: "defaultUserDefaults".queueLabel())
        if let userDefaults = userDefaults {
            self.userDefaults = UserDefaultsWorker(userDefaults: userDefaults, queue: userDefaultsQueue)
        } else {
            self.userDefaults = UserDefaultsWorker(suiteName: "defaultUserDefaults".userDefaultsSuitName(), queue: userDefaultsQueue)
        }
        self.serviceManager = ServiceManager(
            apiClient: apiClient ?? URLSessionClient(
                session: URLSession.defaultSession()
            ),
            writeKey: config.writeKey
        )
        self.sourceConfigDownloader = sourceConfigDownloader ?? SourceConfigDownloader(
            serviceManager: self.serviceManager,
            controlPlaneUrl: config.controlPlaneURL
        )
        self.dataUploader = dataUploader
        self.flushPolicies = [
            CountBasedFlushPolicy(config: config)
        ]
        if !config.flushPolicies.isEmpty {
            self.flushPolicies.append(contentsOf: config.flushPolicies)
        }
        trackApplicationState()
        recordScreenViews()
        fetchSourceConfig()
    }
}

extension Controller {
    func trackApplicationState() {
        applicationSate = ApplicationState.current(
            notificationCenter: NotificationCenter.default,
            userDefaults: self.userDefaults
        )
        applicationSate?.observeNotifications()
        applicationSate?.trackApplicationStateMessage = { [weak self] applicationStateMessage in
            guard let self = self, self.config.trackLifecycleEvents else { return }
            self.track(applicationStateMessage.state.eventName, properties: applicationStateMessage.properties)
        }
        applicationSate?.refreshSessionIfNeeded = { [weak self] in
            guard let self = self, self.config.trackLifecycleEvents else { return }
            self.refreshSessionIfNeeded()
        }
    }
    
    func recordScreenViews() {
        screenRecording = ScreenRecording()
        screenRecording?.capture = { [weak self] screenViewsMessage in
            guard let self = self, self.config.recordScreenViews else { return }
            self.screen(screenViewsMessage.screenName, properties: screenViewsMessage.properties)
        }
    }
    
    func fetchSourceConfig() {
        let sourceConfigDownloadRetryFactors = RetryFactors(
            retryPreset: DownloadUploadRetryPreset.defaultDownload(),
            current: TimeInterval(1)
        )
        
        let sourceConfigDownloadRetryPolicy = config.sourceConfigDownloadRetryPolicy ?? ExponentialRetryPolicy(
            retryFactors: sourceConfigDownloadRetryFactors
        )
        
        let downloader = SourceConfigDownloadWorker(
            sourceConfigDownloader: sourceConfigDownloader,
            downloadBlockers: downloadUploadBlockers,
            userDefaults: userDefaults,
            queue: DispatchQueue(
                label: "sourceConfigDownload".queueLabel(),
                autoreleaseFrequency: .workItem,
                target: .global(qos: .utility)
            ),
            logger: logger,
            retryStrategy: DownloadUploadRetryStrategy(
                retryPolicy: sourceConfigDownloadRetryPolicy
            )
        )
        
        sourceConfigDownload = SourceConfigDownload(downloader: downloader)
        
        sourceConfigDownload?.sourceConfig = { [weak self] sourceConfig in
            guard let self = self else { return }
            self.isEnable = sourceConfig.enabled
            self.updateSourceConfig(sourceConfig)
            self.userDefaults.write(.sourceConfig, value: sourceConfig)
            if self.dataUpload == nil {
                let dataUploadRetryFactors = RetryFactors(
                    retryPreset: DownloadUploadRetryPreset.defaultUpload(
                        minTimeout: TimeInterval(self.config.sleepTimeOut)
                    ),
                    current: TimeInterval(self.config.sleepTimeOut)
                )
                
                let dataUploadRetryPolicy = self.config.dataUploadRetryPolicy ?? ExponentialRetryPolicy(
                    retryFactors: dataUploadRetryFactors
                )
                
                let dataResidency = DataResidency(
                    dataResidencyServer: self.config.dataResidencyServer,
                    sourceConfig: sourceConfig
                )
                
                let dataUploader = self.dataUploader ?? DataUploader(
                    serviceManager: self.serviceManager,
                    anonymousId: self.userDefaults.read(.anonymousId) ?? "",
                    gzipEnabled: self.config.gzipEnabled,
                    dataPlaneUrl: dataResidency.dataPlaneUrl ?? self.config.dataPlaneURL
                )

                let uploader = DataUploadWorker(
                    dataUploader: dataUploader,
                    dataUploadBlockers: self.downloadUploadBlockers,
                    storageWorker: self.storageWorker,
                    config: self.config,
                    queue: DispatchQueue(
                        label: "dataUploadWorker".queueLabel(),
                        autoreleaseFrequency: .workItem,
                        target: .global(qos: .utility)
                    ),
                    logger: self.logger,
                    retryStrategy: DownloadUploadRetryStrategy(
                        retryPolicy: dataUploadRetryPolicy
                    )
                )
                self.dataUpload = DataUpload(uploader: uploader)
            } else {
                if !sourceConfig.enabled {
                    self.dataUpload?.cancel()
                } else {
                    let dataResidency = DataResidency(dataResidencyServer: self.config.dataResidencyServer, sourceConfig: sourceConfig)
                    self.dataUploader?.updateDataPlaneUrl(dataResidency.dataPlaneUrl ?? self.config.dataPlaneURL)
                }
            }
        }
    }
}

extension Controller {
    func updateSourceConfig(_ sourceConfig: SourceConfig) {
        pluginList.forEach { (_, value) in
            value.forEach { plugin in
                plugin.sourceConfig = sourceConfig
            }
        }
    }
    
    func addPlugin(_ plugin: Plugin) {
        if var list = pluginList[plugin.type] {
            list.addPlugin(plugin)
            pluginList[plugin.type] = list
        }
    }
    
    func removePlugin(_ plugin: Plugin) {
        PluginType.allCases.forEach { pluginType in
            if var pluginList = pluginList[pluginType] {
                let removeList = pluginList.filter({ $0 === plugin })
                removeList.forEach({ pluginList.removePlugin($0) })
            }
        }
    }
    
    func getPluginList(by pluginType: PluginType) -> [Plugin]? {
        return pluginList[pluginType]
    }
    
    func getPlugin<T: Plugin>(type: T.Type) -> T? {
        var filteredList = [Plugin]()
        PluginType.allCases.forEach { pluginType in
            if let pluginList = pluginList[pluginType] {
                filteredList.append(contentsOf: pluginList.filter({ $0 is T }))
            }
        }
        return filteredList.first as? T
    }
    
    func associatePlugins(_ handler: (Plugin) -> Void) {
        PluginType.allCases.forEach { pluginType in
            if let pluginList = pluginList[pluginType] {
                pluginList.forEach { plugin in
                    handler(plugin)
                    if let plugin = plugin as? DestinationPlugin {
                        plugin.associate(handler: handler)
                    }
                }
            }
        }
    }
}

extension Controller {
    func track(_ eventName: String, properties: TrackProperties? = nil, option: MessageOption? = nil) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard eventName.isNotEmpty else {
            logger.logWarning(.eventNameNotEmpty)
            return
        }
        let message = TrackMessage(event: eventName, properties: properties, option: option)
        process(message: message)
    }
    
    func screen(_ screenName: String, category: String? = nil, properties: ScreenProperties? = nil, option: MessageOption? = nil) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard screenName.isNotEmpty else {
            logger.logWarning(.screenNameNotEmpty)
            return
        }
        var screenProperties = ScreenProperties()
        if let properties = properties {
            screenProperties = properties
        }
        screenProperties["name"] = screenName
        let message = ScreenMessage(title: screenName, category: category, properties: screenProperties, option: option)
        process(message: message)
    }
    
    func group(_ groupId: String, traits: [String: String]? = nil, option: MessageOption? = nil) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard groupId.isNotEmpty else {
            logger.logWarning(.groupIdNotEmpty)
            return
        }
        let message = GroupMessage(groupId: groupId, traits: traits, option: option)
        process(message: message)
    }
    
    func alias(_ newId: String, option: MessageOption? = nil) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard newId.isNotEmpty else {
            logger.logWarning(.newIdNotEmpty)
            return
        }
        let previousId: String? = userDefaults.read(.userId)
        userDefaults.write(.userId, value: newId)
        var dict: [String: Any] = ["id": newId]
        if let json: JSON = userDefaults.read(.traits), let traits = json.dictionaryValue {
            dict.merge(traits) { (_, new) in new }
        }
        userDefaults.write(.traits, value: try? JSON(dict))
        let message = AliasMessage(newId: newId, previousId: previousId, option: option)
        process(message: message)
    }
    
    func identify(_ userId: String, traits: IdentifyTraits? = nil, option: IdentifyOptionType? = nil) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard userId.isNotEmpty else {
            logger.logWarning(.userIdNotEmpty)
            return
        }
        userDefaults.write(.userId, value: userId)
        
        if let traits = traits {
            userDefaults.write(.traits, value: try? JSON(traits))
        }
        
        if let externalIds = option?.externalIds {
            userDefaults.write(.externalId, value: try? JSON(externalIds))
        }
        let message = IdentifyMessage(userId: userId, traits: traits, option: option)
        process(message: message)
    }
    
    func process(message: Message) {
        let message = message.applyRawEventData(userInfo: userInfo)
        if !isEnable {
            logger.logDebug(.sourceDisabled)
            return
        }
        
        switch message {
        case let e as TrackMessage:
            process(e)
        case let e as IdentifyMessage:
            process(e)
        case let e as ScreenMessage:
            process(e)
        case let e as GroupMessage:
            process(e)
        case let e as AliasMessage:
            process(e)
        default:
            break
        }
        
        @discardableResult
        func process<T: Message>(_ message: T) -> T? {
            let defaultMesage = register(message: message, for: .default)
            register(message: defaultMesage, for: .destination)
            
            @discardableResult
            func register(message: T?, for pluginType: PluginType) -> T? {
                if let list = pluginList[pluginType], let msg = message {
                    return list.process(message: msg)
                }
                return message
            }
            return defaultMesage
        }
        flushPolicies.forEach { flushPolicy in
            flushPolicy.updateState()
            if flushPolicy.shouldFlush() {
                flush()
                flushPolicy.reset()
            }
        }
    }
}

extension Controller {
    var anonymousId: String? {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        return userDefaults.read(.anonymousId)
    }
    
    var userId: String? {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        return userDefaults.read(.userId)
    }
    
    var context: Context? {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        if let currentContext: Context = sessionStorage.read(.context) {
            return currentContext
        }
        return Context(userDefaults: userDefaults)
    }
    
    var traits: IdentifyTraits? {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        let traitsJSON: JSON? = Context.traits(userDefaults: userDefaults)
        return traitsJSON?.dictionaryValue
    }
    
    var version: String {
        return RSVersion
    }
    
    var configuration: Config? {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        return config
    }
    
    var sessionId: String? {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self), let sessionId = userSessionPlugin.sessionId {
            return "\(sessionId)"
        }
        return nil
    }
}

extension Controller {
    func flush() {
        dataUpload?.flush()
        associatePlugins { plugin in
            if let plugin = plugin as? DestinationPlugin {
                plugin.flush()
            }
        }
    }
    
    func reset(and refreshAnonymousId: Bool) {
        if refreshAnonymousId {
            userDefaults.write(.anonymousId, value: Utility.getUniqueId())
        }
        reset()
    }
    
    func reset() {
        resetUserDefaults()
        associatePlugins { plugin in
            if let plugin = plugin as? DestinationPlugin {
                plugin.reset()
            }
        }
    }
}

extension Controller {
    func setAnonymousId(_ anonymousId: String) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        guard anonymousId.isNotEmpty else {
            logger.logWarning(.anonymousIdNotEmpty)
            return
        }
        userDefaults.write(.anonymousId, value: anonymousId)
    }
    
    func setOption(_ option: Option) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        sessionStorage.write(.defaultOption, value: option)
    }
    
    func setDeviceToken(_ token: String) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        guard token.isNotEmpty else {
            logger.logWarning(.tokenNotEmpty)
            return
        }
        sessionStorage.write(.deviceToken, value: token)
    }
    
    func setAdvertisingId(_ advertisingId: String) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        guard advertisingId.isNotEmpty else {
            logger.logWarning(.advertisingIdNotEmpty)
            return
        }
        if advertisingId != "00000000-0000-0000-0000-000000000000" {
            sessionStorage.write(.advertisingId, value: advertisingId)
        }
    }
    
    func setAppTrackingConsent(_ appTrackingConsent: AppTrackingConsent) {
        if let optOutStatus: Bool = userDefaults.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        sessionStorage.write(.appTrackingConsent, value: appTrackingConsent)
    }
    
    func setOptOutStatus(_ status: Bool) {
        userDefaults.write(.optStatus, value: status)
        logger.logDebug(.userOptOut(status))
    }

}

extension Controller {
    func resetUserDefaults() {
        userDefaults.remove(.traits)
        userDefaults.remove(.externalId)
        userDefaults.remove(.userId)
    }
}

extension [Plugin] {
    mutating func addPlugin(_ plugin: Plugin) {
        append(plugin)
    }
    
    mutating func removePlugin(_ plugin: Plugin) {
        removeAll(where: { $0 === plugin })
    }
    
    func process<T: Message>(message: T) -> T? {
        var finalMessage: T? = message
        
        forEach { (plugin) in
            if let msg = finalMessage {
                if plugin is DestinationPlugin {
                    _ = plugin.process(message: msg)
                } else {
                    finalMessage = plugin.process(message: msg)
                }
            }
        }
        
        return finalMessage
    }
}

extension String {
    func queueLabel(_ name: String? = nil) -> String {
        if let name = name {
            return "\(self).\(name).rudder.com"
        }
        return "\(self).rudder.com"
    }
    
    func userDefaultsSuitName(_ name: String? = nil) -> String {
        if let name = name {
            return "\(self).\(name).userDefaults.rudder.com"
        }
        return "\(self).userDefaults.rudder.com"
    }
}
