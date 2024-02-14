//
//  RSReplayQueuePlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

internal class ReplayQueuePlugin: Plugin {
    var type: PluginType = .default
    
    var sourceConfig: SourceConfig? {
        didSet {
            if let value = sourceConfig, value.enabled {
                running = false
                replayEvents()
            } else {
                running = true
            }
        }
    }
    
    var client: RudderProtocol?

    private let queue: DispatchQueue
    private var queuedMessageList = [Message]()
    @ReadWriteLock var running = true
    
    let maxSize = Constants.storageCountThreshold.default
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
        
    func process<T>(message: T?) -> T? where T: Message {
        guard let message = message else { return message }
        if running {
            queue.async { [weak self] in
                guard let self = self else { return }
                if self.queuedMessageList.count >= self.maxSize {
                    self.queuedMessageList.removeFirst()
                }
                self.queuedMessageList.append(message)
            }
        } else {
            processToAllDestinations([message])
        }
        return message
    }
}

extension ReplayQueuePlugin {
    private func replayEvents() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.processToAllDestinations(self.queuedMessageList)
            self.queuedMessageList.removeAll()
        }
    }
    
    private func processToAllDestinations(_ messageList: [Message]) {
        guard let destinationPlugins = client?.getDestinationPlugins(), !destinationPlugins.isEmpty, !messageList.isEmpty else {
            return
        }
        messageList.forEach { message in
            destinationPlugins.forEach { plugin in
                switch message {
                case let e as TrackMessage:
                    _ = plugin.track(message: e)
                case let e as IdentifyMessage:
                    _ = plugin.identify(message: e)
                case let e as ScreenMessage:
                    _ = plugin.screen(message: e)
                case let e as GroupMessage:
                    _ = plugin.group(message: e)
                case let e as AliasMessage:
                    _ = plugin.alias(message: e)
                default:
                    break
                }
            }
        }
    }
}
