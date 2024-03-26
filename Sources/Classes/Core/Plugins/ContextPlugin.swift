//
//  RSContextPlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class ContextPlugin: Plugin {
    var type: PluginType = .default
    
    var client: RSClientProtocol? {
        didSet {
            initialSetup()
        }
    }
    
    var sourceConfig: SourceConfig?
    
    private var staticContext = staticContextData()
    private static var device = Device.current
    private var userDefaultsWorker: UserDefaultsWorkerProtocol?
    
    func initialSetup() {
        guard let client = self.client else { return }
        userDefaultsWorker = client.userDefaultsWorker
    }
    
    func process<T>(message: T?) -> T? where T: Message {
        guard var workingMessage = message else { return message }
        var context = staticContext
        insertDynamicPlatformContextData(context: &context)
        insertDynamicOptionData(message: workingMessage, context: &context)
        insertDynamicDeviceInfoData(context: &context)
        insertSessionData(message: workingMessage, context: &context)
        if let eventContext = workingMessage.context {
            context.merge(eventContext) { (new, _) in new }
        }
        workingMessage.context = context
        client?.sessionStorage.write(.context, value: context)
        return workingMessage
    }
    
    internal static func staticContextData() -> [String: Any] {
        var staticContext = [String: Any]()
        // library name
        staticContext["library"] = Context.LibraryInfo().dictionary
        // app info
        staticContext["app"] = Context.AppInfo().dictionary
        insertStaticPlatformContextData(context: &staticContext)
        return staticContext
    }
    
    internal static func insertStaticPlatformContextData(context: inout [String: Any]) {
        // device
        context["device"] = Context.DeviceInfo().dictionary
        // os
        context["os"] = Context.OSInfo().dictionary
        // screen
        context["screen"] = Context.ScreenInfo().dictionary
        // locale
        context["locale"] = Context.locale()
        // timezone
        context["timezone"] = Context.timezone()
    }
    
    internal func insertDynamicPlatformContextData(context: inout [String: Any]) {
        // network connectivity
        context["network"] = Context.NetworkInfo().dictionary
    }
    
    internal func insertDynamicDeviceInfoData(context: inout [String: Any]) {
        if let deviceToken: String = client?.sessionStorage.read(.deviceToken) {
            context[keyPath: "device.token"] = deviceToken
        }
        if let advertisingId: String = client?.sessionStorage.read(.advertisingId), advertisingId.isNotEmpty {
            context[keyPath: "device.advertisingId"] = advertisingId
            context[keyPath: "device.adTrackingEnabled"] = true
        }
        let appTrackingConsent: AppTrackingConsent = client?.sessionStorage.read(.appTrackingConsent) ?? .notDetermined
        context[keyPath: "device.attTrackingStatus"] = appTrackingConsent.rawValue
    }
    
    func insertDynamicOptionData(message: Message, context: inout [String: Any]) {
        insertExternalIds(message: message, context: &context)
        insertCustomContext(message: message, context: &context)
    }
    
    func insertExternalIds(message: Message, context: inout [String: Any]) {
        var mergedExternalIds = [ExternalId]()
        /// Merging the externalIds from the persistence if there were any, as a result of previous identify calls.
        if let externalIdsFromPersistence: [ExternalId] = userDefaultsWorker?.read(.externalId) {
            mergedExternalIds.add(externalIdsFromPersistence)
        }
        /// Merging the externalIds from the `option` object of the current message if it is not an identify, if any duplicates found, we will override it.
        /// We are not merging the message level `externalIds` in case of Identify Message, because they are already written to the UserDefaults.
        if message.type != .identify,  let option = message.option as? MessageOption, let externalIdsFromMessage = option.externalIds {
            mergedExternalIds.add(externalIdsFromMessage)
        }
        /// Setting the merged externalIds into the context object.
        if !mergedExternalIds.isEmpty {
            context["externalId"] = mergedExternalIds.array
        }
    }
    
    func insertCustomContext(message: Message, context: inout [String: Any]) {
        var mergedCustomContexts = [String: Any]()
        /// Merging the custom context from the `defaultOption` object passed while initializing the SDK
        if let globalOption: GlobalOptionType = client?.sessionStorage.read(.globalOption), let globalCustomContexts = globalOption.customContexts  {
            mergedCustomContexts.merge(globalCustomContexts) { _, incoming in
                incoming
            }
        }
        /// Merging the custom context from the `option` object of the current message, if any duplicate keys found, we will override it.
        if let option = message.option as? MessageOption, let customContextsFromMessage = option.customContexts {
            mergedCustomContexts.merge(customContextsFromMessage) { _, incoming in
                incoming
            }
        }
        /// Setting the merged custom context into the context object.
        if !mergedCustomContexts.isEmpty {
            for (key, value) in mergedCustomContexts {
                context[key] = value
            }
        }
    }
    
    func insertSessionData(message: Message, context: inout [String: Any]) {
        if let sessionId = message.sessionId {
            context["sessionId"] = sessionId
            if let sessionStart = message.sessionStart, sessionStart {
                context["sessionStart"] = sessionStart
            }
        }
    }
}
