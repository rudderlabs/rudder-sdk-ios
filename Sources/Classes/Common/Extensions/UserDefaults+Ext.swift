//
//  UserDefaults+Ext.swift
//  RudderStack
//
//  Created by Pallab Maiti on 13/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension PropertyListDecoder {
    func optionalDecode<T: Decodable>(_ type: T.Type, from object: Any?) -> T? {
        if let data = object as? Data {
            return try? PropertyListDecoder().decode(T.self, from: data)
        }
        return nil
    }
}

extension UserDefaults {
    var serverConfig: RSServerConfig? {
        get {
            return PropertyListDecoder().optionalDecode(RSServerConfig.self, from: object(forKey: RSServerConfigKey))
        }
        set {
            if let newValue = newValue {
                set(try? PropertyListEncoder().encode(newValue), forKey: RSServerConfigKey)
            } else {
                set(nil, forKey: RSServerConfigKey)
            }
        }
    }
    
    var lastUpdateTime: Int? {
        get { integer(forKey: RSServerLastUpdatedKey) }
        set { setValue(newValue, forKey: RSServerLastUpdatedKey) }
    }
    
    var applicationVersion: String? {
        get { string(forKey: RSApplicationVersionKey) }
        set { setValue(newValue, forKey: RSApplicationVersionKey) }
    }
    
    var applicationBuild: String? {
        get { string(forKey: RSApplicationBuildKey) }
        set { setValue(newValue, forKey: RSApplicationBuildKey) }
    }
    
    var externalIds: String? {
        get { string(forKey: RSExternalIdKey) }
        set { setValue(newValue, forKey: RSExternalIdKey) }
    }
    
    var anonymousId: String? {
        get { string(forKey: RSAnonymousIdKey) }
        set { setValue(newValue, forKey: RSAnonymousIdKey) }
    }
    
    var optStatus: Bool? {
        get { bool(forKey: RSOptStatusKey) }
        set { setValue(newValue, forKey: RSOptStatusKey) }
    }
    
    var optInTime: Int? {
        get { integer(forKey: RSOptInTimeKey) }
        set { setValue(newValue, forKey: RSOptInTimeKey) }
    }
    
    var optOutTime: Int? {
        get { integer(forKey: RSOptOutTimeKey) }
        set { setValue(newValue, forKey: RSOptOutTimeKey) }
    }
    
    var sessionId: Int? {
        get { integer(forKey: RSSessionIdKey) }
        set { setValue(newValue, forKey: RSSessionIdKey) }
    }
    
    var lastEventTimeStamp: Int? {
        get { integer(forKey: RSLastEventTimeStamp) }
        set { setValue(newValue, forKey: RSLastEventTimeStamp) }
    }
    
    var automaticTrackingStatus: Bool? {
        get { bool(forKey: RSSessionAutoTrackStatus) }
        set { setValue(newValue, forKey: RSSessionAutoTrackStatus) }
    }
    
    var manualTrackingStatus: Bool? {
        get { bool(forKey: RSSessionManualTrackStatus) }
        set { setValue(newValue, forKey: RSSessionManualTrackStatus) }
    }
    
    var sessionStoppedStatus: Bool? {
        get { bool(forKey: RSSessionStoppedStatus) }
        set { setValue(newValue, forKey: RSSessionStoppedStatus) }
    }
    
    var traits: Data? {
        get { data(forKey: RSTraitsKey) }
        set { setValue(newValue, forKey: RSTraitsKey) }
    }
    
    var userId: String? {
        get { string(forKey: RSUserIdKey) }
        set { setValue(newValue, forKey: RSUserIdKey) }
    }
}
