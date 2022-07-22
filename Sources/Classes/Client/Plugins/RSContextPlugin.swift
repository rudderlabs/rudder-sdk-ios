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
    weak var client: RSClient?
    
    private var staticContext = staticContextData()
    private static var device = Vendor.current
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        var context = staticContext
        insertDynamicPlatformContextData(context: &context)
        insertDynamicOptionData(message: workingMessage, context: &context)
        insertDynamicDeviceInfoData(eventContext: workingMessage.context, context: &context)
        if let eventContext = workingMessage.context {
            context.merge(eventContext) { (new, _) in new }
        }
        workingMessage.context = context
        
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
            "name": info?["CFBundleDisplayName"] ?? (info?["CFBundleName"] ?? ""),
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
        
        let deviceInfo: [String: Any] = [
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
            context["locale"] = "\(Locale.preferredLanguages[0])-\(Locale.current.regionCode ?? "")"
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
    
    internal func insertDynamicDeviceInfoData(eventContext: [String: Any]?, context: inout [String: Any]) {
        if let eventDeviceInfo = eventContext?["device"] as? [String: Any], var existingDeviceInfo = context["device"] as? [String: Any] {
            existingDeviceInfo.merge(eventDeviceInfo) { (new, _) in new }
            context["device"] = existingDeviceInfo
        }
    }
    
    func insertDynamicOptionData(message: RSMessage, context: inout [String: Any]) {
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
    }
}
