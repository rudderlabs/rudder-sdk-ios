//
//  RSPreferenceManager.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 12/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

@objc open class RSPreferenceManager: NSObject {
    
    private static let instance: RSPreferenceManager = RSPreferenceManager()
    private let RSPrefsKey: String = "rl_prefs"
    private let RSServerConfigKey: String = "rl_server_config"
    private let RSServerLastUpdatedKey: String = "rl_server_last_updated"
    private let RSTraitsKey: String = "rl_traits"
    private let RSApplicationInfoKey: String = "rl_application_info_key"
    private let RSExternalIdKey: String =  "rl_external_id"
    private let RSAnonymousIdKey: String =  "rl_anonymous_id"
    
    @objc public static func getInstance() -> RSPreferenceManager {
        return instance
    }
    
    private override init() {
        
    }
    
    func updateLastUpdatedTime(updatedTime: Double) {
        UserDefaults.standard.setValue(updatedTime, forKey: RSServerLastUpdatedKey)
        UserDefaults.standard.synchronize()
    }
    
    func getLastUpdatedTime() -> Double {
        let updatedTime: Double? = UserDefaults.standard.value(forKey: RSServerLastUpdatedKey) as? Double
        if(updatedTime == nil)
        {
            return -1
        }
        else
        {
            return updatedTime! as Double
        }
    }
    
    func saveConfigJson(configJson: String) {
        UserDefaults.standard.setValue(configJson, forKey: RSServerConfigKey)
        UserDefaults.standard.synchronize()
    }
    
    func getConfigJson() -> String? {
        return UserDefaults.standard.value(forKey: RSServerConfigKey) as? String
    }
    
    func saveTraits(traits: String) {
        UserDefaults.standard.setValue(traits, forKey: RSTraitsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getTraits() -> String? {
        return UserDefaults.standard.value(forKey: RSTraitsKey) as? String
    }
    
    func saveBuildVersionCode(versionCode: String)
    {
        UserDefaults.standard.setValue(versionCode, forKey: RSApplicationInfoKey)
        UserDefaults.standard.synchronize()
    }
    
    func getBuildVersionCode() -> String? {
        return UserDefaults.standard.value(forKey: RSApplicationInfoKey) as? String
    }
    
    func saveExternalIds(externalIdsJson: String)
    {
        UserDefaults.standard.setValue(externalIdsJson, forKey: RSExternalIdKey)
        UserDefaults.standard.synchronize()
    }
    
    func getExternalIds() -> String? {
        return UserDefaults.standard.value(forKey: RSExternalIdKey) as? String
    }
    
    func clearExternalIds() {
        UserDefaults.standard.setValue(nil, forKey: RSExternalIdKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAnonymousId() -> String? {
        var anonymousId: String? = UserDefaults.standard.value(forKey: RSAnonymousIdKey) as? String
        if(anonymousId == nil)
        {
            anonymousId = UIDevice.current.identifierForVendor?.uuidString.lowercased()
        }
        saveAnonymousId(anonymousId: anonymousId!)
        return anonymousId
    }
    
    func saveAnonymousId(anonymousId: String) {
        UserDefaults.standard.setValue(anonymousId, forKey: RSAnonymousIdKey)
        UserDefaults.standard.synchronize()
    }
}
