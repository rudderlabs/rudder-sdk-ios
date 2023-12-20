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
    
    private let instanceName: String
    private let syncQueue: DispatchQueue
    private var queuedEvents = [RSMessage]()
    @RSAtomic var running = true
    static let maxSize = 1000
    
    init(instanceName: String) {
        self.instanceName = instanceName
        self.syncQueue = DispatchQueue(label: "replayQueue.rudder.\(instanceName).com")
    }
    
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
        syncQueue.async {
            // send events to device mode destinations only.
            // we will wait for 2 seconds to finish the destinations to be initialized.
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(2)) { [weak self] in
                guard let self = self else { return }
                self.running = false
                if isSourceEnabled, let destinationPlugins = self.getExternalDestinationPlugins() {
                    for event in self.queuedEvents {
                        destinationPlugins.forEach { plugin in
                            self.process(message: event, to: plugin)
                        }
                    }
                }
                self.queuedEvents.removeAll()
            }
            
        }
    }
    
    private func process(message: RSMessage, to plugin: RSPlugin) {
        switch message {
        case let e as TrackMessage:
            _ = plugin.execute(message: e)
        case let e as IdentifyMessage:
            _ = plugin.execute(message: e)
        case let e as ScreenMessage:
            _ = plugin.execute(message: e)
        case let e as GroupMessage:
            _ = plugin.execute(message: e)
        case let e as AliasMessage:
            _ = plugin.execute(message: e)
        default:
            break
        }
    }
    
    private func getExternalDestinationPlugins() -> [RSDestinationPlugin]? {
        return (self.client?.controller.plugins[.destination]?.plugins as? [RSDestinationPlugin])?.filter({ plugin in
            return plugin.key != RUDDER_DESTINATION_KEY
        })
    }
}
