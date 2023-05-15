//
//  RSContextPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSContextPlugin: RSPlatformPlugin {
    let type: PluginType = .before
    var client: RSClient?
    
    var context: MessageContext?
    
    var traits: MessageTraits? {
        if let traits = context?["traits"] as? MessageTraits {
            return traits
        }
        return nil
    }
    
    private var staticContext = staticContextData()
    private static var device = Vendor.current
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }        
        var context = staticContext
        insertDynamicPlatformContextData(context: &context)
        insertDynamicOptionData(message: workingMessage, context: &context)
        workingMessage.context = context
        self.context = context
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
        ] as [String: Any]
    }
    
    func insertDynamicOptionData(message: RSMessage, context: inout [String: Any]) {
        // First priority will given to the `option` passed along with the event
        if let option = message.option {
            if let externalIds = option.externalIds {
                context["externalId"] = externalIds
            }
            if let customContexts = option.customContexts {
                for (key, value) in customContexts {
                    context[key] = value
                }
            }
        }
        // TODO: Fetch `customContexts` set using setOption API.
    }
}

extension RSClient {
    func updateContext(_ context: MessageContext?) {
        if let contextPlugin = self.find(pluginType: RSContextPlugin.self) {
            contextPlugin.context = context
        }
    }
}
