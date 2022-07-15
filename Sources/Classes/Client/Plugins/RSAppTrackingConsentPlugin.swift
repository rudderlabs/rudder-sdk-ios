//
//  RSAppTrackingConsentPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSAppTrackingConsentPlugin: RSPlatformPlugin {
    let type = PluginType.before
    weak var client: RSClient?
    
    var appTrackingConsent: RSAppTrackingConsent = .notDetermined

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if var context = workingMessage.context {
            if let advertisingId = context[keyPath: "device.advertisingId"] as? String, advertisingId.isNotEmpty {
                context[keyPath: "device.attTrackingStatus"] = appTrackingConsent.rawValue
                workingMessage.context = context
            }
        }
        return workingMessage
    }
}

extension RSClient {
    /**     
     API for app tracking consent management.
     - Parameters:
        - appTrackingConsent: App tracking consent
     # Example #
     ```
     client.setAppTrackingConsent(.authorize)
     ```
     */
    @objc
    public func setAppTrackingConsent(_ appTrackingConsent: RSAppTrackingConsent) {
        if let appTrackingConsentPlugin = self.find(pluginType: RSAppTrackingConsentPlugin.self) {
            appTrackingConsentPlugin.appTrackingConsent = appTrackingConsent
        } else {
            let appTrackingConsentPlugin = RSAppTrackingConsentPlugin()
            appTrackingConsentPlugin.appTrackingConsent = appTrackingConsent
            add(plugin: appTrackingConsentPlugin)
        }
    }
}
