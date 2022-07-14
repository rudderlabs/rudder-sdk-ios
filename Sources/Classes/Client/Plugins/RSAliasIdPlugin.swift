//
//  RSAliasIdPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 31/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
let queue11 = DispatchQueue(label: "com.knowstack.queue11")
class RSAliasIdPlugin: RSPlatformPlugin {
    let type = PluginType.before
    weak var client: RSClient?
    
    var id: String?

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        queue11.sync {
            if let id = id {
                if var context = workingMessage.context {
                    context[keyPath: "traits.id"] = id
                    workingMessage.context = context
                    client?.updateContext(context)
                }
            }
        }
        return workingMessage
    }
}

extension RSClient {
    internal func setAlias(_ id: String) {
        queue11.sync {
            if let aliasIdPlugin = self.find(pluginType: RSAliasIdPlugin.self) {
                aliasIdPlugin.id = id
            } else {
                let aliasIdPlugin = RSAliasIdPlugin()
                aliasIdPlugin.id = id
                add(plugin: aliasIdPlugin)
            }
        }
    }
}
