//
//  RSReplayQueuePlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

internal class RSReplayQueuePlugin: RSPlugin {
    let type: PluginType = .before
    weak var client: RSClient?
    
    private let syncQueue = DispatchQueue(label: "replayQueue.rudder.com")
    private var queuedEvents = [RSMessage]()
    @RSAtomic var running = true
    static let maxSize = 1000
    
    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        if running, let e = message {
            syncQueue.async { [weak self] in
                guard let self = self else { return }
                if self.queuedEvents.count >= Self.maxSize {
                    self.queuedEvents.removeFirst()
                }
                self.queuedEvents.append(e)
            }
        }
        return message
    }
    
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        if type == .refresh {
            replayEvents(isSourceEnabled: serverConfig.enabled)
        } else if type == .initial, serverConfig.enabled {
            // if source config is cached and source is enabled. we no longer need to add the events to queue.
            running = false
        }
    }
}

extension RSReplayQueuePlugin {
    internal func replayEvents(isSourceEnabled: Bool) {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            // send events to device mode destinations only.
            // we will wait for 2 seconds to finish the destinations to be initialized.
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(2)) { [weak self] in
                guard let self = self else { return }
                self.running = false
                if isSourceEnabled {
                    if let destinationPlugins = self.getExternalDestinationPlugins() {
                        for event in self.queuedEvents {
                            destinationPlugins.forEach { plugin in
                                _ = plugin.execute(message: event)
                            }
                        }
                    }
                }
                self.queuedEvents.removeAll()
            }
            
        }
    }
    
    private func getExternalDestinationPlugins() -> [RSDestinationPlugin]? {
        return (self.client?.controller.plugins[.destination]?.plugins as? [RSDestinationPlugin])?.filter({ plugin in
            return plugin.key != RUDDER_DESTINATION_KEY
        })
    }
}
