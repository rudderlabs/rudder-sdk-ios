//
//  RSUserIdPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 01/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
let queue10 = DispatchQueue(label: "com.knowstack.queue10")
class RSUserIdPlugin: RSPlatformPlugin {
    let type = PluginType.before
    weak var client: RSClient?
    
    var userId: String?

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        queue10.sync {
            if let userId = userId {
                workingMessage.userId = userId
                if var context = workingMessage.context {
                    context[keyPath: "traits.userId"] = userId
                    workingMessage.context = context
                    client?.updateContext(context)
                }
            }
        }
        return workingMessage
    }
}

extension RSClient {
    // TODO: Called from identify and alias - Needs to be synchronised
    internal func setUserId(_ userId: String) {
        queue10.sync {
            if let userIdPlugin = self.find(pluginType: RSUserIdPlugin.self) {
                userIdPlugin.userId = userId
            } else {
                let userIdPlugin = RSUserIdPlugin()
                userIdPlugin.userId = userId
                add(plugin: userIdPlugin)
            }
        }
    }    
}

extension AliasMessage {
    internal func applyAlias(newId: String, client: RSClient) -> Self {
        queue10.sync {
            var result: Self = self
            result.userId = newId
            if let userIdPlugin = client.find(pluginType: RSUserIdPlugin.self), let previousId = userIdPlugin.userId {
                result.previousId = previousId
            }
            return result
        }
    }
}
