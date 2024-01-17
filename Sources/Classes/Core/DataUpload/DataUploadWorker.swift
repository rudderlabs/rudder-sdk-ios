//
//  DataUploadWorker.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

protocol DataUploadWorkerType {
    func flushSynchronously()
    func cancel()
}

class DataUploadWorker: DataUploadWorkerType {
    let dataUploader: DataUploaderType
    let dataUploadBlockers: DownloadUploadBlockersProtocol
    let storageWorker: StorageWorker
    let config: Config
    let queue: DispatchQueue
    let logger: Logger
    let retryStrategy: DownloadUploadRetryStrategy
    
    @ReadWriteLock
    var readWorkItem: DispatchWorkItem?
    
    @ReadWriteLock
    var uploadWorkItem: DispatchWorkItem?
    
    init(
        dataUploader: DataUploaderType,
        dataUploadBlockers: DownloadUploadBlockersProtocol,
        storageWorker: StorageWorker,
        config: Config,
        queue: DispatchQueue,
        logger: Logger,
        retryStrategy: DownloadUploadRetryStrategy
    ) {
        self.dataUploader = dataUploader
        self.dataUploadBlockers = dataUploadBlockers
        self.storageWorker = storageWorker
        self.config = config
        self.queue = queue
        self.logger = logger
        self.retryStrategy = retryStrategy
        self.readWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let blockersForUpload = dataUploadBlockers.get()
            let messageList = blockersForUpload.isEmpty ? storageWorker.fetchMessages(limit: config.flushQueueSize) : nil
            if let messageList = messageList, !messageList.isEmpty {
                self.flush(messageList: messageList)
            } else {
                self.flushNextBatch()
            }
        }
        flushNextBatch(TimeInterval(0))
    }
    
    func flush(messageList: [StorageMessage]) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let uploadStatus = self.dataUploader.upload(messages: messageList)
            if uploadStatus.needsRetry {
                if self.retryStrategy.shouldRetry() {
                    self.retryStrategy.increase()
                    self.flushNextBatch()
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
                switch error {
                case .httpError(let statusCode):
                    self.logger.logError(.flushAbortedWithStatusCode(statusCode))
                case .networkError(let error):
                    self.logger.logError(.flushAbortedWithErrorDescription(error.localizedDescription))
                case .noResponse:
                    self.logger.logError(.noResponse)
                }
            }
            self.flushNextBatch()
        }
        self.uploadWorkItem = workItem
        queue.async(execute: workItem)
    }
    
    func flushNextBatch(_ interval: TimeInterval? = nil) {
        guard let readWorkItem = readWorkItem else {
            return
        }
        queue.asyncAfter(deadline: .now() + (interval ?? retryStrategy.current), execute: readWorkItem)
    }
    
    func flushSynchronously() {
        queue.sync { [weak self] in
            guard let self = self,
                  let messageList = storageWorker.fetchMessages(limit: config.dbCountThreshold),
                  let batches = getBatches(messageList: messageList) else {
                return
            }
            for batch in batches {
                defer {
                    self.storageWorker.clearMessages(batch.messages)
                }
                _ = self.dataUploader.upload(messages: batch.messages)
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
        let totalBatch = (messageList.count % config.flushQueueSize == 0) ? (messageList.count / config.flushQueueSize) : ((messageList.count / config.flushQueueSize) + 1)
        guard totalBatch >= 1 else {
            return nil
        }
        var batches = [FlushBatch]()
        for i in 0..<totalBatch {
            var batch: FlushBatch
            if i == totalBatch - 1 {
                batch = FlushBatch(messages: Array(messageList[(i * config.flushQueueSize)..<messageList.count]))
            } else {
                batch = FlushBatch(messages: Array(messageList[(i * config.flushQueueSize)..<((i + 1) * config.flushQueueSize)]))
            }
            batches.append(batch)
        }
        return batches
    }
}

struct FlushBatch {
    let messages: [StorageMessage]
}
