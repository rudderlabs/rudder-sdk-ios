//
//  RSReplayQueuePlugin.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

internal class ReplayQueuePlugin: Plugin {
    var type: PluginType = .default
    
    var sourceConfig: SourceConfig? {
        didSet {
            if oldValue == nil {
                if let value = oldValue, value.enabled {
                    running = false
                }
            } else {
                if let value = sourceConfig {
                    replayEvents(isSourceEnabled: value.enabled)
                }
            }
        }
    }
    
    var client: RSClient?

    private let queue: DispatchQueue
    private var queuedMessageList = [Message]()
    @ReadWriteLock var running = true
    
    let maxSize = Constants.storageCountThreshold.default
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
        
    func process<T>(message: T?) -> T? where T: Message {
        if running, let msg = message {
            queue.async { [weak self] in
                guard let self = self else { return }
                if self.queuedMessageList.count >= self.maxSize {
                    self.queuedMessageList.removeFirst()
                }
                self.queuedMessageList.append(msg)
            }
        }
        return message
    }
}

extension ReplayQueuePlugin {
    internal func replayEvents(isSourceEnabled: Bool) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.running = false
            guard isSourceEnabled else {
                return
            }
            if let destinationPlugins = self.client?.controller.getPluginList(by: .destination) {
                self.queuedMessageList.forEach { message in
                    destinationPlugins.forEach { plugin in
                        self.process(message, for: plugin)
                    }
                }
            }
            self.queuedMessageList.removeAll()
        }
    }
    
    func process(_ message: Message, for plugin: Plugin) {
        switch message {
        case let e as TrackMessage:
            _ = plugin.process(message: e)
        case let e as IdentifyMessage:
            _ = plugin.process(message: e)
        case let e as ScreenMessage:
            _ = plugin.process(message: e)
        case let e as GroupMessage:
            _ = plugin.process(message: e)
        case let e as AliasMessage:
            _ = plugin.process(message: e)
        default:
            break
        }
    }
}
