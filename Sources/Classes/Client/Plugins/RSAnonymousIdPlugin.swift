//
//  RSAnonymousIdPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 02/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSAnonymousIdPlugin: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient?
    
    var anonymousId = UUID().uuidString.lowercased()

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        guard var workingMessage = message else { return message }
        workingMessage.anonymousId = anonymousId
        if var context = workingMessage.context {
            context[keyPath: "traits.anonymousId"] = anonymousId
            workingMessage.context = context
            client?.updateContext(context)
        }
        return workingMessage
    }
}

extension RSClient {
    /**
     API for setting unique identifier of every call.
     - Parameters:
        - anonymousId: Unique identifier of every event
     # Example #
     ```
     client.setAnonymousId("sample_anonymous_id")
     ```
     */
    @objc
    public func setAnonymousId(_ anonymousId: String) {
        guard anonymousId.isNotEmpty else {
            log(message: "anonymousId can not be empty", logLevel: .warning)
            return
        }
        if let anonymousIdPlugin = self.find(pluginType: RSAnonymousIdPlugin.self) {
            anonymousIdPlugin.anonymousId = anonymousId
        } else {
            let anonymousIdPlugin = RSAnonymousIdPlugin()
            anonymousIdPlugin.anonymousId = anonymousId
            add(plugin: anonymousIdPlugin)
        }
    }
}
