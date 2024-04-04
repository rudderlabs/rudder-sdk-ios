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
    
    var client: RudderProtocol?
        
    func process<T>(message: T?) -> T? where T: Message {
        guard var workingMessage = message else { return message }
       /// Retrieving the integrations status passed using `globalOption` object passed while initializing the SDK
        let globalOption: GlobalOptionType? = client?.sessionStorage.read(.globalOption)
        let globalOptionIntegrationsStatus = globalOption?.integrationsStatus ?? [:]
        
        /// Retrieving the integrations status passed using `option` object from the current message.
        let messageIntegrationsStatus = workingMessage.option?.integrationsStatus ?? [:]
        
        /// Merging the integrations status from global `option` object with the ones from the message level `option` object and if there are any duplicate integrations in both the `option` objects, we are considering the integration status passed from `message level option` object.
        var mergedIntegrationsStatus = globalOptionIntegrationsStatus.merging(messageIntegrationsStatus) { (_, incoming) in incoming }
        
        if mergedIntegrationsStatus["All"] == nil {
            mergedIntegrationsStatus["All"] = true
        }
        workingMessage.integrations = mergedIntegrationsStatus
        return workingMessage
    }
}
