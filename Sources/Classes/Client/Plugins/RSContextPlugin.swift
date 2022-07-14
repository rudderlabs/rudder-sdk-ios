//
//  RSContextPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
private let syncQueue = DispatchQueue(label: "context.rudder.com")
class RSContextPlugin: RSPlatformPlugin {
    let type: PluginType = .before
    weak var client: RSClient?
    
    var context: MessageContext?
    
    var traits: MessageTraits? {
        if let traits = context?["traits"] as? MessageTraits {
            return traits
        }
        return nil
    }
    
    private var staticContext = staticContextData()
    private static var device = Vendor.current
    let semaphore = DispatchSemaphore(value: 1)
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        syncQueue.sync {
            var context = staticContext
            insertDynamicPlatformContextData(context: &context)
            insertDynamicOptionData(message: workingMessage, context: &context)
            workingMessage.context = context
            self.context = context
        }
        return workingMessage
    }
    
    internal static func staticContextData() -> [String: Any] {
        var staticContext = [String: Any]()
        
        // library name
        staticContext["library"] = [
            "name": "rudder-ios-library",
            "version": RSVersion
        ]
        
        // app info
        let info = Bundle.main.infoDictionary
        staticContext["app"] = [
            "name": info?["CFBundleDisplayName"] ?? "",
            "version": info?["CFBundleShortVersionString"] ?? "",
            "build": info?["CFBundleVersion"] ?? "",
            "namespace": Bundle.main.bundleIdentifier ?? ""
        ]
        insertStaticPlatformContextData(context: &staticContext)
        return staticContext
    }
    
    internal static func insertStaticPlatformContextData(context: inout [String: Any]) {
        // device
        let device = Self.device
        
        let deviceInfo = [
            "manufacturer": device.manufacturer,
            "type": device.type,
            "model": device.model,
            "name": device.name,
            "id": device.identifierForVendor ?? ""
        ]
        context["device"] = deviceInfo
        // os
        context["os"] = [
            "name": device.systemName,
            "version": device.systemVersion
        ]
        // screen
        let screen = device.screenSize
        context["screen"] = [
            "width": screen.width,
            "height": screen.height,
            "density": screen.density
        ]
        // locale
        if !Locale.preferredLanguages.isEmpty {
            context["locale"] = Locale.preferredLanguages[0]
        }
        // timezone
        context["timezone"] = TimeZone.current.identifier
    }

    internal func insertDynamicPlatformContextData(context: inout [String: Any]) {
        let device = Self.device
        
        // network
        let status = device.connection
        
        var cellular = false
        var wifi = false
        var bluetooth = false
        
        switch status {
        case .online(.cellular):
            cellular = true
        case .online(.wifi):
            wifi = true
        case .online(.bluetooth):
            bluetooth = true
        default:
            break
        }
        
        // network connectivity
        context["network"] = [
            "bluetooth": bluetooth,
            "cellular": cellular,
            "wifi": wifi,
            "carrier": device.carrier
        ]
    }
    
    func insertDynamicOptionData(message: RSMessage, context: inout [String: Any]) {
        if let option = message.option {
            if let externalIds = option.externalIds {
                context["externalId"] = externalIds
            }
            if let customContexts = option.customContexts {
                for key in customContexts.keys {
                    context[key] = [key: customContexts]
                }
            }
        }
    }

}
extension RSClient {
    
    func updateContext(_ context: MessageContext?) {
        syncQueue.sync {
            if let contextPlugin = self.find(pluginType: RSContextPlugin.self) {
                contextPlugin.context = context
            }
        }
    }
}
