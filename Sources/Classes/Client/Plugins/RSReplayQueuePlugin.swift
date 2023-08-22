//
//  RSReplayQueuePlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

internal class RSReplayQueuePlugin: RSPlugin {
    static let maxSize = 1000

    @RSAtomic var running: Bool = true
    
    let type: PluginType = .before
    
    var client: RSClient?
    
    let syncQueue = DispatchQueue(label: "replayQueue.rudder.com")
    var queuedEvents = [RSMessage]()
    
    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        if running == true, let e = message {
            syncQueue.sync {
                if queuedEvents.count >= Self.maxSize {
                    queuedEvents.removeFirst()
                }
                queuedEvents.append(e)
            }
            return nil
        }
        return message
    }
    
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard client?.checkServerConfigInProgress == true else { return }
        running = false
        replayEvents()
    }
}

extension RSReplayQueuePlugin {
    internal func replayEvents() {
        syncQueue.sync {
            for event in queuedEvents {
                client?.process(message: event)
            }
            queuedEvents.removeAll()
        }
    }
}
