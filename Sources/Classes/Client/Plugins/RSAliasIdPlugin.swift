//
//  RSAliasIdPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 31/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSAliasIdPlugin: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient?
    
    var id: String?

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        if let id = id {
            if var context = workingMessage.context {
                context[keyPath: "traits.id"] = id
                workingMessage.context = context
                client?.updateContext(context)
            }
        }
        return workingMessage
    }
}

extension RSAliasIdPlugin: RSEventPlugin {
    func reset() {
        id = nil
    }
}

extension RSClient {
    internal func setAlias(_ id: String) {
        if let aliasIdPlugin = self.find(pluginType: RSAliasIdPlugin.self) {
            aliasIdPlugin.id = id
        } else {
            let aliasIdPlugin = RSAliasIdPlugin()
            aliasIdPlugin.id = id
            add(plugin: aliasIdPlugin)
        }
    }
}
