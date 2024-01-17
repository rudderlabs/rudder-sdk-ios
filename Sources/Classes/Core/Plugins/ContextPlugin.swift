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
    
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    var sourceConfig: SourceConfig?
    
    private var staticContext = staticContextData()
    private static var device = Device.current
    private var userDefaults: UserDefaultsWorkerType?
    
    func initialSetup() {
        guard let client = self.client else { return }
        userDefaults = client.controller.userDefaults
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
        client?.controller.sessionStorage.write(.context, value: context)
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
        if let deviceToken: String = client?.controller.sessionStorage.read(.deviceToken) {
            context[keyPath: "device.token"] = deviceToken
        }
        if let advertisingId: String = client?.controller.sessionStorage.read(.advertisingId), advertisingId.isNotEmpty {
            context[keyPath: "device.advertisingId"] = advertisingId
            context[keyPath: "device.adTrackingEnabled"] = true
        }
        let appTrackingConsent: AppTrackingConsent = client?.controller.sessionStorage.read(.appTrackingConsent) ?? .notDetermined
        context[keyPath: "device.attTrackingStatus"] = appTrackingConsent.rawValue
    }
    
    func insertDynamicOptionData(message: Message, context: inout [String: Any]) {
        // First priority will given to the `option` passed along with the event
        var contextExternalIds = [[String: String]]()
        // Fetch `externalIds` set using identify API.
        if let externalIds: [[String: String]] = userDefaults?.read(.externalId) {
            contextExternalIds.append(contentsOf: externalIds)
        }
        
        if let option = message.option {
            // We will merge the external ids for other event calls
            if let option = option as? IdentifyOption, let externalIds = option.externalIds {
                contextExternalIds.append(contentsOf: externalIds)
            }
            if let customContexts = option.customContexts {
                for (key, value) in customContexts {
                    context[key] = value
                }
            }
        }
        if !contextExternalIds.isEmpty {
            context["externalId"] = contextExternalIds
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
