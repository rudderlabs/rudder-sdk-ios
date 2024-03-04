//
//  Controller.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSClientCore {
    let configuration: Configuration
    let storage: Storage
    let storageWorker: StorageWorkerProtocol
    let userDefaultsWorker: UserDefaultsWorkerProtocol
    let serviceManager: ServiceType
    let sourceConfigDownloader: SourceConfigDownloaderType
    let logger: Logger
    let instanceName: String
    let downloadUploadBlockers: DownloadUploadBlockers = DownloadUploadBlockers()
    let sessionStorage: SessionStorageProtocol = SessionStorage()
    var database: Database?
    var applicationSate: ApplicationState?
    var screenRecording: ScreenRecording?
    var dataUpload: DataUpload?
    var dataUploader: DataUploaderType?
    var sourceConfigDownload: SourceConfigDownload?
    var flushPolicies: [FlushPolicy]
    @ReadWriteLock var pluginList: [PluginType: [Plugin]] = [
        .default: [Plugin](),
        .destination: [Plugin]()
    ]
    var userInfo: UserInfo {
        let userId: String? = userDefaultsWorker.read(.userId)
        let traits: JSON? = userDefaultsWorker.read(.traits)
        var anonymousId: String? = userDefaultsWorker.read(.anonymousId)
        if anonymousId == nil {
            anonymousId = Utility.getUniqueId()
            userDefaultsWorker.write(.anonymousId, value: anonymousId)
        }
        return UserInfo(anonymousId: anonymousId, userId: userId, traits: traits)
    }
    @ReadWriteLock var isEnable: Bool = true
    
    init(
        configuration: Configuration,
        instanceName: String,
        database: Database? = nil,
        storage: Storage? = nil,
        userDefaults: UserDefaults? = nil,
        sourceConfigDownloader: SourceConfigDownloaderType? = nil,
        dataUploader: DataUploaderType? = nil,
        apiClient: APIClient? = nil,
        applicationState: ApplicationState? = nil
    ) {
        self.configuration = configuration
        self.instanceName = instanceName
        self.logger = Logger(
            logger: configuration.logger ?? ConsoleLogger(
                logLevel: configuration.logLevel,
                instanceName: instanceName
            )
        )
        if let storage = storage {
            self.storage = storage
        } else {
            let defaultDatabase = SQLiteDatabase(
                path: Device.current.directoryPath,
                name: "rl_persistence_\(instanceName).sqlite"
            )
            self.database = defaultDatabase
            let defaultStorage = SQLiteStorage(
                database: defaultDatabase,
                logger: self.logger
            )
            self.storage = defaultStorage
        }
        
        self.storageWorker = StorageWorker(
            storage: self.storage,
            queue: DispatchQueue(label: "defaultStorageWorker".queueLabel(instanceName))
        )
        self.storageWorker.open()
        let userDefaultsQueue = DispatchQueue(label: "defaultUserDefaults".queueLabel(instanceName))
        if let userDefaults = userDefaults {
            self.userDefaultsWorker = UserDefaultsWorker(userDefaults: userDefaults, queue: userDefaultsQueue)
        } else {
            self.userDefaultsWorker = UserDefaultsWorker(suiteName: "defaultUserDefaults".userDefaultsSuitName(instanceName), queue: userDefaultsQueue)
        }
        self.serviceManager = ServiceManager(
            apiClient: apiClient ?? URLSessionClient(
                session: URLSession.defaultSession()
            ),
            writeKey: configuration.writeKey
        )
        self.sourceConfigDownloader = sourceConfigDownloader ?? SourceConfigDownloader(
            serviceManager: self.serviceManager,
            controlPlaneUrl: configuration.controlPlaneURL
        )
        self.dataUploader = dataUploader
        self.flushPolicies = [
            CountBasedFlushPolicy(config: configuration)
        ]
        if !configuration.flushPolicies.isEmpty {
            self.flushPolicies.append(contentsOf: configuration.flushPolicies)
        }
        trackApplicationState()
        recordScreenViews()
        fetchSourceConfig()
        logConfigValidationErrors()
    }
    
}

extension RSClientCore {
    private func trackApplicationState() {
        applicationSate = ApplicationState.current(
            notificationCenter: NotificationCenter.default,
            userDefaults: self.userDefaultsWorker
        )
        applicationSate?.observeNotifications()
        applicationSate?.trackApplicationStateMessage = { [weak self] applicationStateMessage in
            guard let self = self, self.configuration.trackLifecycleEvents else { return }
            self.track(applicationStateMessage.state.eventName, properties: applicationStateMessage.properties)
        }
        applicationSate?.refreshSessionIfNeeded = { [weak self] in
            guard let self = self, self.configuration.trackLifecycleEvents else { return }
            self.refreshSessionIfNeeded()
        }
    }
    
    private func recordScreenViews() {
        screenRecording = ScreenRecording()
        screenRecording?.capture = { [weak self] screenViewsMessage in
            guard let self = self, self.configuration.recordScreenViews else { return }
            self.screen(screenViewsMessage.screenName, properties: screenViewsMessage.properties)
        }
    }
    
    private func fetchSourceConfig() {
        let sourceConfigDownloadRetryFactors = RetryFactors(
            retryPreset: DownloadUploadRetryPreset.defaultDownload(),
            current: TimeInterval(1)
        )
        
        let sourceConfigDownloadRetryPolicy = configuration.sourceConfigDownloadRetryPolicy ?? ExponentialRetryPolicy(
            retryFactors: sourceConfigDownloadRetryFactors
        )
        
        let downloader = SourceConfigDownloadWorker(
            sourceConfigDownloader: sourceConfigDownloader,
            downloadBlockers: downloadUploadBlockers,
            userDefaults: userDefaultsWorker,
            queue: DispatchQueue(
                label: "sourceConfigDownload".queueLabel(instanceName),
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
            if needsDatabaseMigration {
                self.migrateStorage()
            }
            self.isEnable = sourceConfig.enabled
            self.updateSourceConfig(sourceConfig)
            self.userDefaultsWorker.write(.sourceConfig, value: sourceConfig)
            if self.dataUpload == nil {
                let dataUploadRetryFactors = RetryFactors(
                    retryPreset: DownloadUploadRetryPreset.defaultUpload(
                        minTimeout: TimeInterval(self.configuration.sleepTimeOut)
                    ),
                    current: TimeInterval(self.configuration.sleepTimeOut)
                )
                
                let dataUploadRetryPolicy = self.configuration.dataUploadRetryPolicy ?? ExponentialRetryPolicy(
                    retryFactors: dataUploadRetryFactors
                )
                
                let dataResidency = DataResidency(
                    dataResidencyServer: self.configuration.dataResidencyServer,
                    sourceConfig: sourceConfig
                )
                
                let dataUploader = self.dataUploader ?? DataUploader(
                    serviceManager: self.serviceManager,
                    anonymousId: self.userDefaultsWorker.read(.anonymousId) ?? "",
                    gzipEnabled: self.configuration.gzipEnabled,
                    dataPlaneUrl: dataResidency.dataPlaneUrl ?? self.configuration.dataPlaneURL
                )

                let uploader = DataUploadWorker(
                    dataUploader: dataUploader,
                    dataUploadBlockers: self.downloadUploadBlockers,
                    storageWorker: self.storageWorker,
                    config: self.configuration,
                    queue: DispatchQueue(
                        label: "dataUploadWorker".queueLabel(self.instanceName),
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
                    let dataResidency = DataResidency(dataResidencyServer: self.configuration.dataResidencyServer, sourceConfig: sourceConfig)
                    self.dataUploader?.updateDataPlaneUrl(dataResidency.dataPlaneUrl ?? self.configuration.dataPlaneURL)
                }
            }
        }
    }
    
    private func logConfigValidationErrors() {
        configuration.configValidationErrorList.forEach({ logger.logWarning(LogMessages.customMessage($0.description)) })
    }
    
    private func migrateStorage() {
        if let storageMigrator = storageMigrator {
            storageMigration = StorageMigration(storageMigrator: storageMigrator)
        } else {
            let oldDatabase = SQLiteDatabase(path: Device.current.directoryPath, name: "rl_persistence.sqlite")
            let oldSQLiteStorage = SQLiteStorage(database: oldDatabase, logger: logger)
            let storageMigrator = StorageMigratorV1V2(oldSQLiteStorage: oldSQLiteStorage, currentStorage: storage)
            storageMigration = StorageMigration(storageMigrator: storageMigrator)
        }
        do {
            try storageMigration?.migrate()
            logger.logDebug(.storageMigrationSuccess)
        } catch {
            if let error = error as? StorageError {
                if error == .databaseNotExists {
                    logger.logDebug(.customMessage(error.description))
                } else {
                    logger.logError(.storageMigrationFailed(error))
                }
            } else {
                logger.logDebug(.customMessage(error.localizedDescription))
            }
        }
    }
}

extension RSClientCore {
    func updateSourceConfig(_ sourceConfig: SourceConfig) {
        pluginList.forEach { (_, value) in
            value.forEach { plugin in
                plugin.sourceConfig = sourceConfig
            }
        }
    }
    #warning("add sync queue")
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
    
    func getAllPlugins() -> [Plugin]? {
        return pluginList.flatMap { (_, value) in
            return value
        }
    }
    
    func getDestinationPlugins() -> [DestinationPlugin]? {
        return getPluginList(by: .destination) as? [DestinationPlugin]
    }
    
    func getDefaultPlugins() -> [Plugin]? {
        return getPluginList(by: .default)
    }
    
    private func getPluginList(by pluginType: PluginType) -> [Plugin]? {
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

extension RSClientCore {
    func track(_ eventName: String, properties: TrackProperties? = nil, option: MessageOption? = nil) {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
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
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
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
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
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
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard newId.isNotEmpty else {
            logger.logWarning(.newIdNotEmpty)
            return
        }
        let previousId: String? = userDefaultsWorker.read(.userId)
        userDefaultsWorker.write(.userId, value: newId)
        var dict: [String: Any] = ["id": newId]
        if let json: JSON = userDefaultsWorker.read(.traits), let traits = json.dictionaryValue {
            dict.merge(traits) { (_, new) in new }
        }
        userDefaultsWorker.write(.traits, value: try? JSON(dict))
        let message = AliasMessage(newId: newId, previousId: previousId, option: option)
        process(message: message)
    }
    
    func identify(_ userId: String, traits: IdentifyTraits? = nil, option: IdentifyOptionType? = nil) {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOutAndEventDrop)
            return
        }
        guard userId.isNotEmpty else {
            logger.logWarning(.userIdNotEmpty)
            return
        }
        userDefaultsWorker.write(.userId, value: userId)
        
        if let traits = traits {
            userDefaultsWorker.write(.traits, value: try? JSON(traits))
        }
        
        if let externalIds = option?.externalIds {
            userDefaultsWorker.write(.externalId, value: try? JSON(externalIds))
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

extension RSClientCore {
    var anonymousId: String? {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        return userDefaultsWorker.read(.anonymousId)
    }
    
    var userId: String? {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        return userDefaultsWorker.read(.userId)
    }
    
    var context: Context? {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        if let currentContext: Context = sessionStorage.read(.context) {
            return currentContext
        }
        return Context(userDefaults: userDefaultsWorker)
    }
    
    var traits: IdentifyTraits? {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        let traitsJSON: JSON? = Context.traits(userDefaults: userDefaultsWorker)
        return traitsJSON?.dictionaryValue
    }
    
    var version: String {
        return RSVersion
    }
    
    var sessionId: Int? {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return nil
        }
        if let userSessionPlugin = getPlugin(type: UserSessionPlugin.self), let sessionId = userSessionPlugin.sessionId {
            return sessionId
        }
        return nil
    }
}

extension RSClientCore {
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
            userDefaultsWorker.write(.anonymousId, value: Utility.getUniqueId())
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

extension RSClientCore {
    func setAnonymousId(_ anonymousId: String) {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        guard anonymousId.isNotEmpty else {
            logger.logWarning(.anonymousIdNotEmpty)
            return
        }
        userDefaultsWorker.write(.anonymousId, value: anonymousId)
    }
    
    func setOption(_ option: Option) {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        sessionStorage.write(.defaultOption, value: option)
    }
    
    func setDeviceToken(_ token: String) {
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
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
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
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
        if let optOutStatus: Bool = userDefaultsWorker.read(.optStatus), optOutStatus {
            logger.logDebug(.optOut)
            return
        }
        sessionStorage.write(.appTrackingConsent, value: appTrackingConsent)
    }
    
    func setOptOutStatus(_ status: Bool) {
        userDefaultsWorker.write(.optStatus, value: status)
        logger.logDebug(.userOptOut(status))
    }

}

extension RSClientCore {
    func resetUserDefaults() {
        userDefaultsWorker.remove(.traits)
        userDefaultsWorker.remove(.externalId)
        userDefaultsWorker.remove(.userId)
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
        if let name = name, name.isNotEmpty {
            return "\(self).\(name).rudder.com"
        }
        return "\(self).rudder.com"
    }
    
    func userDefaultsSuitName(_ name: String? = nil) -> String {
        if let name = name, name.isNotEmpty {
            return "\(self).\(name).userDefaults.rudder.com"
        }
        return "\(self).userDefaults.rudder.com"
    }
}

extension String {
    var correctified: String {
        return self.isEmpty ? ClientRegistry.defaultInstanceName : self
    }
}
