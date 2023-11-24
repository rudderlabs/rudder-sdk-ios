//
//  RSUserDefaults.swift
//  RudderStack
//
//  Created by Pallab Maiti on 17/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSUserDefaults {    
    enum Keys: String, CaseIterable {
        case userId
        case traits
        case anonymousId
        case lastUpdateTime
        case serverConfig
        case optStatus
        case optInTime
        case optOutTime
        case context
        case externalId
        case sessionId
        case lastEventTimeStamp
        case automaticSessionTrackingStatus
        case manualSessionTrackingStatus
        case sessionStoppedStatus
    }
    
    enum ApplicationKeys: String {
        case version
        case build
    }
    
    let syncQueue = DispatchQueue(label: "userDefaults.rudder.com")
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
        
    func write<T: Codable>(_ key: RSUserDefaults.Keys, value: T?) {
        syncQueue.sync {
            if isBasicType(value: value) {
                userDefaults.set(value, forKey: key.rawValue)
            } else {
                userDefaults.set(try? PropertyListEncoder().encode(value), forKey: key.rawValue)
            }
            userDefaults.synchronize()
        }
    }
    
    func read<T: Codable>(_ key: RSUserDefaults.Keys) -> T? {
        var result: T?
        syncQueue.sync {
            let raw = userDefaults.object(forKey: key.rawValue)
            if let r = raw as? Data {
                result = PropertyListDecoder().optionalDecode(T.self, from: r)
            } else {
                result = userDefaults.object(forKey: key.rawValue) as? T
            }
        }
        return result
    }
    
    func remove(_ key: RSUserDefaults.Keys) {
        syncQueue.sync {
            userDefaults.removeObject(forKey: key.rawValue)
            userDefaults.synchronize()
        }
    }
    
    func write(application key: RSUserDefaults.ApplicationKeys, value: String?) {
        syncQueue.sync {
            userDefaults.set(value, forKey: key.rawValue)
            userDefaults.synchronize()
        }
    }
    
    func read(application key: RSUserDefaults.ApplicationKeys) -> String? {
        var result: String?
        syncQueue.sync {
            result = userDefaults.string(forKey: key.rawValue)
        }
        return result
    }
    
    func reset() {
        syncQueue.sync {
            userDefaults.removeObject(forKey: RSUserDefaults.Keys.traits.rawValue)
            userDefaults.removeObject(forKey: RSUserDefaults.Keys.externalId.rawValue)
            userDefaults.removeObject(forKey: RSUserDefaults.Keys.userId.rawValue)
        }
    }
}

extension RSUserDefaults {
    func isBasicType<T: Any>(value: T?) -> Bool {
        var result = false
        if value == nil {
            result = true
        } else {
            switch value {
            case is NSNull, is Decimal, is NSNumber, is Bool, is String:
                result = true
            default:
                break
            }
        }
        return result
    }
}

extension PropertyListDecoder {
    func optionalDecode<T: Decodable>(_ type: T.Type, from object: Any?) -> T? {
        if let data = object as? Data {
            return try? PropertyListDecoder().decode(T.self, from: data)
        }
        return nil
    }
}
