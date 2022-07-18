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
    var client: RSClient? {
        didSet {
            initialSetup()
        }
    }
    
    private var userDefaults: RSUserDefaults?
    
    internal func initialSetup() {
        guard let client = self.client else { return }
        userDefaults = client.userDefaults
    }
    
    required init() { }
    
    func execute<T: RSMessage>(message: T?) -> T? {
        if getOptOutStatus() == true {
            client?.log(message: "User Opted out for tracking the activity, hence dropping the event", logLevel: .debug)
            return nil
        } else {
            return message
        }
    }
}

extension RSGDPRPlugin {
    internal func getOptOutStatus() -> Bool {
        let optStatus: Bool? = userDefaults?.read(.optStatus)
        return optStatus ?? false
    }
}

extension RSClient {
    @objc
    public func setOptOutStatus(_ status: Bool) {
        userDefaults.write(.optStatus, value: status)
    }
}
