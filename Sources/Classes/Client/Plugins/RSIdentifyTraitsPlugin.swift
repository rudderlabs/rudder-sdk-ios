//
//  RSIdentifyTraitsPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 31/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
private let syncQueue = DispatchQueue(label: "identityTraits.rudder.com")
class RSIdentifyTraitsPlugin: RSPlatformPlugin {
    let type = PluginType.before
    weak var client: RSClient?
    
    var traits: IdentifyTraits?

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        syncQueue.sync {
            if let traits = traits {
                if var context = workingMessage.context {
                    context["traits"] = traits
                    workingMessage.context = context
                    client?.updateContext(context)
                }
            }
        }
        return workingMessage
    }
}

extension RSClient {
    internal func setTraits(_ traits: IdentifyTraits?) {
        syncQueue.sync {
            if let traitsPlugin = self.find(pluginType: RSIdentifyTraitsPlugin.self) {
                traitsPlugin.traits = traits
            } else {
                let traitsPlugin = RSIdentifyTraitsPlugin()
                traitsPlugin.traits = traits
                add(plugin: traitsPlugin)
            }
        }
    }
}
