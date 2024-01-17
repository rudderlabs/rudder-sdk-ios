//
//  StoragePlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class StoragePlugin: Plugin {
    var type: PluginType = .default
    
    var client: RSClient? {
        didSet {
            storageWorker = client?.controller.storageWorker
        }
    }
    
    var sourceConfig: SourceConfig?
    var storageWorker: StorageWorker?
    
    func process<T>(message: T?) -> T? where T: Message {
        guard let message = message else { return message }
        do {
            let messageString = try message.toString.get()
            // we are assigning random UUID string
            // for DefaultDatabase we don't need the id as the table is auto incremented
            storageWorker?.saveMessage(StorageMessage(id: UUID().uuidString, message: messageString))
        } catch {
            client?.logError(LogMessages.failedJSONConversion(error.localizedDescription).description)
        }
        return message
    }
}
