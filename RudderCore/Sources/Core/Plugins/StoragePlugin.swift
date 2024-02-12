//
//  StoragePlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

class StoragePlugin: Plugin {
    var type: PluginType = .default
    
    var client: RudderProtocol? {
        didSet {
            storageWorker = client?.storageWorker
        }
    }
    
    var sourceConfig: SourceConfig?
    var storageWorker: StorageWorkerProtocol?
    
    func process<T>(message: T?) -> T? where T: Message {
        guard let message = message else { return message }
        do {
            let messageString = try message.toString()
            
            guard messageString.getUTF8Length() <= Constants.messageSize.default else {
                client?.logger.logError(.internalErrors(.maxBatchSize(Constants.messageSize.default)))
                return message
            }
            // we are assigning random UUID string
            // for DefaultDatabase we don't need the id as the table is auto incremented
            storageWorker?.saveMessage(StorageMessage(id: UUID().uuidString, message: messageString, updated: .getTimeStamp()))
        } catch {
            if let err = error as? InternalErrors {
                client?.logger.logError(.internalErrors(err))
            } else {
                client?.logger.logError(error.localizedDescription)
            }
        }
        return message
    }
}
