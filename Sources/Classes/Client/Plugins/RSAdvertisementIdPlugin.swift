//
//  RSAdvertisementIdPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSAdvertisingIdPlugin: RSPlatformPlugin {
    let type = PluginType.before
    weak var client: RSClient?
    
    var advertisingId: String?

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if var context = workingMessage.context, let advertisingId = advertisingId, advertisingId != "00000000-0000-0000-0000-000000000000" {
            context[keyPath: "device.advertisingId"] = advertisingId
            context[keyPath: "device.adTrackingEnabled"] = true
            workingMessage.context = context
        }
        return workingMessage
    }
}

extension RSClient {
    /**
     API for setting identifier under context.device.advertisingId.
     - Parameters:
        - advertisingId: IDFA value
     # Example #
     ```
     client.setAdvertisingId("sample_advertising_id")
     ```
     */
    @objc
    public func setAdvertisingId(_ advertisingId: String) {
        guard advertisingId.isNotEmpty else {
            log(message: "advertisingId can not be empty", logLevel: .warning)
            return
        }
        if let advertisingIdPlugin = self.find(pluginType: RSAdvertisingIdPlugin.self) {
            advertisingIdPlugin.advertisingId = advertisingId
        } else {
            let advertisingIdPlugin = RSAdvertisingIdPlugin()
            advertisingIdPlugin.advertisingId = advertisingId
            add(plugin: advertisingIdPlugin)
        }
    }
}
