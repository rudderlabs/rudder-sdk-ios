//
//  RSIntegrationPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSIntegrationPlugin: RSPlatformPlugin {
    let type: PluginType = .before
    var client: RSClient?
        
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if let messageIntegrations = workingMessage.option?.integrations {
            workingMessage.integrations = messageIntegrations
            if messageIntegrations["All"] == nil {
                workingMessage.integrations?["All"] = true
            }
        } else if let optionPlugin = client?.find(pluginType: RSOptionPlugin.self) {
            if let integrations = optionPlugin.option?.integrations {
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
        return workingMessage
    }
}
