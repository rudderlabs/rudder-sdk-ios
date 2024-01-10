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
    let key: String = RUDDER_DESTINATION_KEY
    let controller = RSController()
    weak var client: RSClient? {
        didSet {
            initialSetup()
        }
    }

    private let uploadsQueue = DispatchQueue(label: "uploadsQueue.rudder.com")
    private var flushTimer: RSRepeatingTimer?
    
    private var databaseManager: RSDatabaseManager?
    private var serviceManager: RSServiceType?
    private var config: RSConfig?
    private var userDefaults: RSUserDefaults?
    
    @RSAtomic var isSourceEnabled = false
    @RSAtomic var isFlushingStarted = false
    
    private let lock = NSLock()
    
    func initialSetup() {
        guard let client = self.client else { return }
        config = client.config
        userDefaults = client.userDefaults
        databaseManager = client.databaseManager
        serviceManager = client.serviceManager
    }
        
    func execute<T: RSMessage>(message: T?) -> T? {
        let result: T? = message
        if let r = result {
            saveEvent(message: r)
        }
        return result
    }
    
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        if type == .refresh {
            if isSourceEnabled, !serverConfig.enabled {
                // if source was enabled before, but it has been disabled now; then cancel flushing
                Logger.logDebug("Source has been disabled in your dashboard. Flushing canceled.")
                flushTimer?.cancel()
            } else if !isSourceEnabled {
                if serverConfig.enabled {
                    // if source was disabled before, but it has been enabled now; then resume flushing
                    Logger.logDebug("Source has been enabled in your dashboard. Flushing resumed.")
                    flushTimer?.resume()
                } else {
                    // if source was disabled before, still it has been disabled now; then cancel flushing
                    Logger.logDebug("Source is still disabled in your dashboard. Flushing canceled.")
                    flushTimer?.cancel()
                }
            }
        }
        isSourceEnabled = serverConfig.enabled
        startFlushing()
    }
    
    func startFlushing() {
        guard !isFlushingStarted else {
            return
        }
        isFlushingStarted = true
        Logger.logDebug("Flushing started.")
        var sleepCount = 0
        flushTimer = RSRepeatingTimer(interval: TimeInterval(1)) { [weak self] in
            guard let self = self else { return }
            self.uploadsQueue.async {
                guard self.isSourceEnabled else {
                    // if source is disabled; then suspend flushing
                    Logger.logDebug("Source is disabled in your dashboard. Flushing suspended.")
                    self.flushTimer?.suspend()
                    return
                }
                guard let recordCount = self.databaseManager?.getDBRecordCount(), let config = self.config else {
                    return
                }
                if recordCount >= config.dbCountThreshold || sleepCount >= config.sleepTimeOut {
                    if recordCount > 0 {
                        self.flushTimer?.suspend()
                        self.flush(sleepCount: 0) { _ in
                            sleepCount = 0
                            self.flushTimer?.resume()
                        }
                    } else {
                        sleepCount = 0
                    }
                } else {
                    sleepCount += 1
                }
            }
        }
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
    
    private func saveEvent<T: RSMessage>(message: T) {
        guard let databaseManager = self.databaseManager else { return }
        databaseManager.write(message)
    }
}

extension RudderDestinationPlugin {
    
    func flush() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let databaseManager = self.databaseManager, let config = self.config else {
                return
            }
            let totalBatchCount = RSUtils.getNumberOfBatch(from: databaseManager.getDBRecordCount(), and: config.flushQueueSize)
            self.flushBatch(index: 0, totalBatchCount: totalBatchCount)
        }
    }
    
    private func flushBatch(index: Int, totalBatchCount: Int) {
        guard index < totalBatchCount else {
            Logger.logDebug("All batches have been flushed successfully")
            return
        }
        Logger.log(message: "Flushing batch \(index + 1)/\(totalBatchCount)", logLevel: .debug)
        flush(retryCount: 0) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                Logger.log(message: "Successful to flush batch \(index + 1)/\(totalBatchCount)", logLevel: .debug)
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(1)) {
                    self.flushBatch(index: index + 1, totalBatchCount: totalBatchCount)
                }
            case .failure:
                Logger.log(message: "Failed to send \(index + 1)/\(totalBatchCount) batch after 3 retries, dropping the remaining batches as well", logLevel: .debug)
            }
        }
        
        func flush(retryCount: Int, completion: @escaping Handler<Bool>) {
            let maxRetryCount = 3
            
            guard retryCount < maxRetryCount else {
                completion(.failure(NSError(code: .SERVER_ERROR)))
                return
            }
            
            flushEventsToServer { result in
                self.lock.unlock()
                switch result {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    if error.code == RSErrorCode.WRONG_WRITE_KEY.rawValue {
                        Logger.log(message: "Wrong write key", logLevel: .error)
                        completion(.failure(error))
                    } else {
                        Logger.log(message: "Failed to flush batch \(index + 1)/\(totalBatchCount), \(3 - retryCount) retries left", logLevel: .debug)
                        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(retryCount)) {
                            flush(retryCount: retryCount + 1, completion: completion)
                        }
                    }
                }
            }
        }
    }
    
    private func flush(sleepCount: Int, completion: @escaping Handler<Bool>) {
        flushEventsToServer { result in
            self.lock.unlock()
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                let errorCode = RSErrorCode(rawValue: error.code)
                switch errorCode {
                case .SERVER_ERROR:
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(sleepCount + 1)) {
                        self.flush(sleepCount: sleepCount + 1, completion: completion)
                    }
                default:
                    Logger.logError("Aborting flush. Error code: \((errorCode ?? RSErrorCode.UNKNOWN).rawValue)")
                    completion(.failure(NSError(code: .UNKNOWN)))
                }
            }
        }
    }

    private func flushEventsToServer(_ completion: Handler<Bool>? = nil) {
        lock.lock()
        guard let databaseManager = databaseManager, let config = config else {
            completion?(.failure(NSError(code: .UNKNOWN)))
            return
        }
        let recordCount = databaseManager.getDBRecordCount()
        Logger.log(message: "DBRecordCount \(recordCount)", logLevel: .debug)
        if recordCount > config.dbCountThreshold {
            Logger.log(message: "Old DBRecordCount \(recordCount - config.dbCountThreshold)", logLevel: .debug)
            let dbMessage = databaseManager.getEvents(recordCount - config.dbCountThreshold)
            if let messageIds = dbMessage?.messageIds {
                databaseManager.removeEvents(messageIds)
            }
        }
        Logger.log(message: "Fetching events to flush to sever", logLevel: .debug)
        guard let dbMessage = databaseManager.getEvents(config.flushQueueSize) else {
            completion?(.failure(NSError(code: .UNKNOWN)))
            return
        }
        if !dbMessage.messages.isEmpty {
            let params = dbMessage.toJSONString()
            Logger.log(message: "Payload: \(params)", logLevel: .debug)
            Logger.log(message: "EventCount: \(dbMessage.messages.count)", logLevel: .debug)
            if !params.isEmpty {
                serviceManager?.flushEvents(params: params, { result in
                    switch result {
                    case .success:
                        Logger.log(message: "clearing events from DB", logLevel: .debug)
                        databaseManager.removeEvents(dbMessage.messageIds)
                        completion?(.success(true))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                })
            } else {
                completion?(.failure(NSError(code: .UNKNOWN)))
            }
        } else {
            completion?(.failure(NSError(code: .UNKNOWN)))
        }
    }
    
    private func periodicFlush() {
        uploadsQueue.async { [weak self] in
            guard let self = self else { return }
            self.flushEventsToServer { _ in
                self.lock.unlock()
            }
        }
    }
}
