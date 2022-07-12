//
//  RudderDestination.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RudderDestinationPlugin: RSDestinationPlugin {
    let type = PluginType.destination
    let key: String = "RudderStack"
    let controller = RSController()
    weak var client: RSClient? {
        didSet {
            initialSetup()
        }
    }

    private let uploadsQueue = DispatchQueue(label: "uploadsQueue.rudder.com")
    private var flushTimer: RSRepeatingTimer?
    
    private var databaseManager: RSDatabaseManager?
    private var serviceManager: RSServiceManager?
    
    private let lock = NSLock()
    
    func initialSetup() {
        guard let client = self.client, let config = client.config else { return }
        databaseManager = RSDatabaseManager(client: client)
        serviceManager = RSServiceManager(client: client)
        flushTimer = RSRepeatingTimer(interval: TimeInterval(config.sleepTimeOut)) { [weak self] in
            guard let self = self else { return }
            self.periodicFlush()
        }
    }
        
    func execute<T: RSMessage>(message: T?) -> T? {
        let result: T? = message
        if let r = result {
            let modified = configureCloudDestinations(message: r)
            queueEvent(message: modified)
        }
        return result
    }
    
    internal func enterForeground() {
        flushTimer?.resume()
    }
    
    internal func enterBackground() {
        flushTimer?.suspend()
        periodicFlush()
    }
    
    internal func willTerminate() {
        enterBackground()
    }
    
    private func queueEvent<T: RSMessage>(message: T) {
        guard let databaseManager = self.databaseManager else { return }
        databaseManager.write(message)
    }
}

extension RudderDestinationPlugin {
    internal func configureCloudDestinations<T: RSMessage>(message: T) -> T {
        guard let serverConfig = client?.serverConfig else { return message }
        guard let plugins = client?.controller.plugins[.destination]?.plugins as? [RSDestinationPlugin] else { return message }
        guard let customerValues = message.integrations else { return message }
        
        var merged = [String: Bool]()
        
        for plugin in plugins {
            var hasSettings = false
            if let destinations = serverConfig.destinations {
                if let destination = destinations.first(where: { $0.destinationDefinition?.displayName == plugin.key }), destination.enabled {
                    hasSettings = true
                }
            }
            if hasSettings {
                merged[plugin.key] = false
            }
        }
        
        for (key, value) in customerValues {
            merged[key] = value
        }
        
        var modified = message
        modified.integrations = merged
        
        return modified
    }
}

extension RudderDestinationPlugin {
    
    func flush() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let databaseManager = self.databaseManager, let config = self.client?.config else {
                return
            }
            let uploadGroup = DispatchGroup()
            let numberOfBatch = RSUtils.getNumberOfBatch(from: databaseManager.getDBRecordCount(), and: config.flushQueueSize)
            for i in 0..<numberOfBatch {
                uploadGroup.enter()
                self.client?.log(message: "Flushing batch \(i + 1)/\(numberOfBatch)", logLevel: .debug)
                var isLastBatchFailed = false
                for count in 1...RETRY_FLUSH_COUNT {
                    let errorCode = self.prepareEventsToFlush()
                    if errorCode == nil {
                        self.client?.log(message: "Successful to flush batch \(i + 1)/\(numberOfBatch)", logLevel: .debug)
                        break
                    }
                    self.client?.log(message: "Failed to flush batch \(i + 1)/\(numberOfBatch), \(3 - count) retries left", logLevel: .debug)
                    if count == RETRY_FLUSH_COUNT {
                        isLastBatchFailed = true
                    }
                }
                if isLastBatchFailed {
                    self.client?.log(message: "Failed to send \(i + 1)/\(numberOfBatch) batch after 3 retries, dropping the remaining batches as well", logLevel: .debug)
                    break
                }
                uploadGroup.leave()
            }
            uploadGroup.wait()
        }
    }
    
    func periodicFlush() {
        uploadsQueue.async { [weak self] in
            guard let self = self else { return }
            self.prepareEventsToFlush()
        }
    }
    
    @discardableResult
    func prepareEventsToFlush() -> RSErrorCode? {
        lock.lock()
        guard let databaseManager = databaseManager, let config = client?.config else {
            return .UNKNOWN
        }
        var errorCode: RSErrorCode?
        let recordCount = databaseManager.getDBRecordCount()
        client?.log(message: "DBRecordCount \(recordCount)", logLevel: .debug)
        if recordCount > config.dbCountThreshold {
            client?.log(message: "Old DBRecordCount \(recordCount - config.dbCountThreshold)", logLevel: .debug)
            let dbMessage = databaseManager.getEvents(recordCount - config.dbCountThreshold)
            if let messageIds = dbMessage?.messageIds {
                databaseManager.removeEvents(messageIds)
            }
        }
        client?.log(message: "Fetching events to flush to sever", logLevel: .debug)
        guard let dbMessage = databaseManager.getEvents(config.flushQueueSize) else {
            return .UNKNOWN
        }
        if dbMessage.messages.isEmpty == false {
            let params = RSUtils.getJSON(from: dbMessage)
            client?.log(message: "Payload: \(params)", logLevel: .debug)
            client?.log(message: "EventCount: \(dbMessage.messages.count)", logLevel: .debug)
            if !params.isEmpty {
                errorCode = self.flushEventsToServer(params: params)
                if errorCode == nil {
                    client?.log(message: "clearing events from DB", logLevel: .debug)
                    databaseManager.removeEvents(dbMessage.messageIds)
                } else if errorCode == .WRONG_WRITE_KEY {
                    client?.log(message: "Wrong WriteKey. Aborting.", logLevel: .error)
                } else if errorCode == .SERVER_ERROR {
                    client?.log(message: "Server error. Aborting.", logLevel: .error)
                }
            }
        }
        lock.unlock()
        return errorCode
    }
    
    func flushEventsToServer(params: String) -> RSErrorCode? {
        var errorCode: RSErrorCode?
        let semaphore = DispatchSemaphore(value: 0)
        serviceManager?.flushEvents(params: params) { result in
            switch result {
            case .success:
                errorCode = nil
            case .failure(let error):
                errorCode = RSErrorCode(rawValue: error.code)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return errorCode
    }
}
