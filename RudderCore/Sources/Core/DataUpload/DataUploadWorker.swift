//
//  DataUploadWorker.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

protocol DataUploadWorkerType {
    func flushSynchronously()
    func cancel()
}

class DataUploadWorker: DataUploadWorkerType {
    let dataUploader: DataUploaderType
    let dataUploadBlockers: DownloadUploadBlockersProtocol
    let storageWorker: StorageWorkerProtocol
    let configuration: Configuration
    let queue: DispatchQueue
    let logger: Logger
    let retryStrategy: DownloadUploadRetryStrategy
    var backgroundTaskPlanner: BackgroundTaskPlanner?
    
    @ReadWriteLock
    var readWorkItem: DispatchWorkItem?
    
    @ReadWriteLock
    var uploadWorkItem: DispatchWorkItem?
    
    init(
        dataUploader: DataUploaderType,
        dataUploadBlockers: DownloadUploadBlockersProtocol,
        storageWorker: StorageWorkerProtocol,
        configuration: Configuration,
        queue: DispatchQueue,
        logger: Logger,
        retryStrategy: DownloadUploadRetryStrategy
    ) {
        self.dataUploader = dataUploader
        self.dataUploadBlockers = dataUploadBlockers
        self.storageWorker = storageWorker
        self.configuration = configuration
        self.queue = queue
        self.logger = logger
        self.retryStrategy = retryStrategy
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            self.backgroundTaskPlanner = UIKitBackgroundTaskPlanner()
        #elseif !targetEnvironment(simulator) && os(watchOS)
            // TODO: The solution is not working. Need to check further.
            // self.backgroundTaskPlanner = WatchKitBackgroundTaskPlanner()
        #endif
        self.readWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let blockersForUpload = dataUploadBlockers.get()
            let messageCount: Int = blockersForUpload.isEmpty ? (self.storageWorker.getMessageCount() ?? 0) : 0
            if messageCount > 0 {
                self.flush()
            } else {
                self.flushInNextCycle()
            }
        }
        flushInNextCycle(TimeInterval(0))
    }
    
    func flush() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let messageList = self.storageWorker.fetchMessages(limit: self.configuration.flushQueueSize),
                  !messageList.isEmpty else {
                return
            }
            let uploadStatus = self.dataUploader.upload(messages: messageList)
            if uploadStatus.needsRetry {
                if self.retryStrategy.shouldRetry() {
                    self.retryStrategy.increase()
                    self.flushInNextCycle()
                    self.logger.logDebug(.retry("flush", self.retryStrategy.current))
                } else {
                    self.logger.logDebug(.retryAborted("flush", self.retryStrategy.retries))
                }
                return
            } else {
                self.retryStrategy.reset()
                self.logger.logDebug(.eventsCleared)
                self.storageWorker.clearMessages(messageList)
            }
            if let error = uploadStatus.error {
                self.logger.logError(.apiError(.flush, error))
            }
            self.flushInNextCycle()
        }
        self.uploadWorkItem = workItem
        queue.async(execute: workItem)
    }
    
    func flushInNextCycle(_ interval: TimeInterval? = nil) {
        guard let readWorkItem = readWorkItem else {
            return
        }
        queue.asyncAfter(deadline: .now() + (interval ?? retryStrategy.current), execute: readWorkItem)
    }
    
    func flushSynchronously() {
        queue.sync { [weak self] in
            guard let self = self,
                  let messageList = self.storageWorker.fetchMessages(limit: self.configuration.dbCountThreshold),
                  let batches = self.getBatches(messageList: messageList) else {
                return
            }
            for batch in batches {
                self.backgroundTaskPlanner?.beginBackgroundTask()
                let uploadStatus = self.dataUploader.upload(messages: batch.messages)
                if let error = uploadStatus.error {
                    self.logger.logDebug(.apiError(.flush, error))
                } else {
                    self.storageWorker.clearMessages(batch.messages)
                }
                self.backgroundTaskPlanner?.endBackgroundTask()
            }
        }
    }
    
    func cancel() {
        queue.sync { [weak self] in
            guard let self = self else {
                return
            }
            self.uploadWorkItem?.cancel()
            self.uploadWorkItem = nil
            self.readWorkItem?.cancel()
            self.readWorkItem = nil
        }
    }
}

extension DataUploadWorker {
    func getBatches(messageList: [StorageMessage]) -> [FlushBatch]? {
        let totalBatch = (messageList.count % configuration.flushQueueSize == 0) ? (messageList.count / configuration.flushQueueSize) : ((messageList.count / configuration.flushQueueSize) + 1)
        guard totalBatch >= 1 else {
            return nil
        }
        var batches = [FlushBatch]()
        for i in 0..<totalBatch {
            var batch: FlushBatch
            if i == totalBatch - 1 {
                batch = FlushBatch(messages: Array(messageList[(i * configuration.flushQueueSize)..<messageList.count]))
            } else {
                batch = FlushBatch(messages: Array(messageList[(i * configuration.flushQueueSize)..<((i + 1) * configuration.flushQueueSize)]))
            }
            batches.append(batch)
        }
        return batches
    }
}

struct FlushBatch {
    let messages: [StorageMessage]
}
