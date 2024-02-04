//
//  ClientRegistry.swift
//  Rudder
//
//  Created by Pallab Maiti on 31/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

/// A registry for all instances.
public class ClientRegistry {
    
    @ReadWriteLock
    static var instances: [String: RSClient] = [:]
    
    /// The name for the default instance.
    public static let defaultInstanceName = "default"
    
    private init() { }
    
    static var `default`: RSClient? {
        instances[defaultInstanceName]
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
    
    static func instance(named name: String) -> RSClient? {
        instances[name]
    }
    
    static func unregisterInstance(named name: String) {
        instances.removeValue(forKey: name)
    }
    
    static func unregisterDefault() {
        unregisterInstance(named: defaultInstanceName)
    }
}
