//
//  CoreRegistry.swift
//  Rudder
//
//  Created by Pallab Maiti on 18/12/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc
open class CoreRegistry: NSObject {
    static var instances: [String: RSClient] = [:]

    public static var `default`: RSClient {
        instances[DEFAULT_INSTANCE_NAME] ?? deadInstance
    }
    
    private static var deadInstance: RSClient {
        let config = RSConfig(writeKey: "DEADINSTANCE_WRITE_KEY")
        return RSClient(instanceName: "DEADINSTANCE", config: config)
    }
    
    static func register(_ instance: RSClient, name: String) {
        guard !isRegistered(instanceName: name) else {
            
            return
        }
        instances[name] = instance
    }
    
    static func isRegistered(instanceName: String) -> Bool {
        return instances[instanceName] != nil
    }
    
    static func instance(named name: String) -> RSClient {
        instances[name] ?? deadInstance
    }
}
