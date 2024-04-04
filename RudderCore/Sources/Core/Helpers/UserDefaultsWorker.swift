//
//  UserDefaultsWorker.swift
//  Rudder
//
//  Created by Pallab Maiti on 17/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public enum UserDefaultsKeys: String {
    case userId = "rs_user_id"
    case traits = "rs_traits"
    case anonymousId = "rs_anonymous_id"
    case sourceConfig = "rs_server_config"
    case optStatus = "rs_opt_status"
    case optInTime = "rs_opt_in_time"
    case optOutTime = "rs_opt_out_time"
    case externalId = "rs_external_id"
    case sessionId = "rl_session_id"
    case lastEventTimeStamp = "rl_last_event_time_stamp"
    case automaticSessionTrackingStatus = "rl_session_auto_track_status"
    case manualSessionTrackingStatus = "rl_session_manual_track_status"
    case sessionStoppedStatus = "rl_session_stopped_status"
    case version = "rs_application_version_key"
    case build = "rs_application_build_key"
}

public protocol UserDefaultsWorkerProtocol {
    func write<T: Codable>(_ key: UserDefaultsKeys, value: T?)
    func read<T: Codable>(_ key: UserDefaultsKeys) -> T?
    func remove(_ key: UserDefaultsKeys)
}

class UserDefaultsWorker: UserDefaultsWorkerProtocol {
    let queue: DispatchQueue
    let userDefaults: UserDefaults?
    
    init(suiteName: String, queue: DispatchQueue) {
        self.userDefaults = UserDefaults(suiteName: suiteName)
        self.queue = queue
    }
    
    init(userDefaults: UserDefaults?, queue: DispatchQueue) {
        self.userDefaults = userDefaults
        self.queue = queue
    }
        
    func write<T: Codable>(_ key: UserDefaultsKeys, value: T?) {
        queue.sync {
            if isBasicType(value: value) {
                userDefaults?.set(value, forKey: key.rawValue)
            } else {
                userDefaults?.set(try? PropertyListEncoder().encode(value), forKey: key.rawValue)
            }
            userDefaults?.synchronize()
        }
    }
    
    func read<T: Codable>(_ key: UserDefaultsKeys) -> T? {
        var result: T?
        queue.sync {
            let raw = userDefaults?.object(forKey: key.rawValue)
            if let r = raw as? Data {
                result = PropertyListDecoder().optionalDecode(T.self, from: r)
            } else {
                result = userDefaults?.object(forKey: key.rawValue) as? T
            }
        }
        return result
    }
    
    func remove(_ key: UserDefaultsKeys) {
        queue.sync {
            userDefaults?.removeObject(forKey: key.rawValue)
            userDefaults?.synchronize()
        }
    }
}

extension UserDefaultsWorker {
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
