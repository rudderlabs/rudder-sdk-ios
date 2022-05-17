//
//  RSGDPRPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 03/03/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSGDPRPlugin: RSPlatformPlugin {
    let type = PluginType.before
    var client: RSClient?
    
    var optOutStatus: Bool?

    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        if RSUserDefaults.getOptStatus() == true {
            return nil
        } else {
            return message
        }
    }
}

extension RSClient {
    @objc
    public func setOptOutStatus(_ status: Bool) {
        RSUserDefaults.saveOptStatus(status)
        if let gdprPlugin = self.find(pluginType: RSGDPRPlugin.self) {
            gdprPlugin.optOutStatus = status
        } else {
            let gdprPlugin = RSGDPRPlugin()
            gdprPlugin.optOutStatus = status
            add(plugin: gdprPlugin)
        }
    }
    
    @objc
    public func getOptOutStatus() -> Bool {
        return RSUserDefaults.getOptStatus() ?? false
    }
}
