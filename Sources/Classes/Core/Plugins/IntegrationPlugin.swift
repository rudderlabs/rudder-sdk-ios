//
//  RSIntegrationPlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class IntegrationPlugin: Plugin {
    var type: PluginType = .default
    var sourceConfig: SourceConfig?
    
    var client: RSClient?
        
    func process<T>(message: T?) -> T? where T: Message {
        guard var workingMessage = message else { return message }
        let messageIntegrations = workingMessage.option?.integrations ?? [:]
        let globalOption: Option? = client?.controller.sessionStorage.read(.defaultOption)
        let globalOptionIntegrations = globalOption?.integrations ?? [:]
        
        var integrations = messageIntegrations.merging(globalOptionIntegrations) { (current, _) in current }
        
        if integrations["All"] == nil {
            integrations["All"] = true
        }
        workingMessage.integrations = integrations
        return workingMessage
    }
}
