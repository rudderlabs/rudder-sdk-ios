//
//  RSSessionStoragePlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 07/12/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

// This class has no use at the moment. But will be needed when multiple instance will come in place. We will remove RSSessionStorage
class RSSessionStoragePlugin: RSPlatformPlugin {
    let type: PluginType = .before
    var client: RSClient?
    
    private var deviceToken: String?
    private var advertisingId: String?
    private var appTrackingConsent: RSAppTrackingConsent?
    private var option: RSOption?

    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if let messageIntegrations = workingMessage.option?.integrations {
            workingMessage.integrations = messageIntegrations
            if messageIntegrations["All"] == nil {
                workingMessage.integrations?["All"] = true
            }
        } else if let globalOption = option {
            if let integrations = globalOption.integrations {
                workingMessage.integrations = integrations
                if integrations["All"] == nil {
                    workingMessage.integrations?["All"] = true
                }
            } else {
                workingMessage.integrations = ["All": true]
            }
        } else {
            workingMessage.integrations = ["All": true]
        }
        return message
    }
    
}
