//
//  RSUserDefaults.swift
//  RudderStack
//
//  Created by Pallab Maiti on 17/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSUserDefaults {
    static func getLastUpdatedTime() -> Int? {
        return UserDefaults.standard.lastUpdateTime
    }
    
    static func updateLastUpdatedTime(_ time: Int) {
        UserDefaults.standard.lastUpdateTime = time
    }
        
    static func getServerConfig() -> RSServerConfig? {
        return UserDefaults.standard.serverConfig
    }
    
    static func saveServerConfig(_ serverConfig: RSServerConfig) {
        UserDefaults.standard.serverConfig = serverConfig
    }
        
    static func getApplicationVersion() -> String? {
        return UserDefaults.standard.applicationVersion
    }
    
    static func saveApplicationVersion(_ version: String?) {
        UserDefaults.standard.applicationVersion = version
    }
    
    static func getApplicationBuild() -> String? {
        return UserDefaults.standard.applicationBuild
    }
    
    static func saveApplicationBuild(_ build: String?) {
        UserDefaults.standard.applicationBuild = build
    }
    
    static func getOptStatus() -> Bool? {
        return UserDefaults.standard.optStatus
    }

    static func saveOptStatus(_ optStatus: Bool) {
        UserDefaults.standard.optStatus = optStatus
    }
    
    static func getOptInTime() -> Int? {
        return UserDefaults.standard.optInTime
    }
    
    static func updateOptInTime(_ optInTime: Int?) {
        UserDefaults.standard.optInTime = optInTime
    }
    
    static func getOptOutTime() -> Int? {
        return UserDefaults.standard.optOutTime
    }
    
    static func updateOptOutTime(_ optOutTime: Int?) {
        UserDefaults.standard.optOutTime = optOutTime
    }
    
    static func saveSessionId(_ sessionId: Int) {
        UserDefaults.standard.sessionId = sessionId
        UserDefaults.standard.synchronize()
    }
    
    static func getSessionId() -> Int? {
        return UserDefaults.standard.sessionId
    }
    
    static func saveLastEventTimeStamp(_ lastEventTimeStamp: Int?) {
        UserDefaults.standard.lastEventTimeStamp = lastEventTimeStamp
        UserDefaults.standard.synchronize()
    }
    
    static func getLastEventTimeStamp() -> Int? {
        if let lastEventTimeStamp = UserDefaults.standard.lastEventTimeStamp, lastEventTimeStamp != 0 {
            return lastEventTimeStamp;
        }
        return nil
    }
    
    static func saveAutomaticSessionTrackingStatus(_ autoTrackingStatus: Bool) {
        UserDefaults.standard.automaticTrackingStatus = autoTrackingStatus
        UserDefaults.standard.synchronize()
    }
    
    static func getAutomaticSessionTrackingStatus() -> Bool? {
        return UserDefaults.standard.automaticTrackingStatus
    }
    
    static func saveManualSessionTrackingStatus(_ manualTrackingStatus: Bool) {
        UserDefaults.standard.manualTrackingStatus = manualTrackingStatus
        UserDefaults.standard.synchronize()
    }
    
    static func getManualSessionTrackingStatus() -> Bool? {
        return UserDefaults.standard.manualTrackingStatus
    }
    
    static func saveSessionStoppedStatus(_ sessionStoppedStatus: Bool) {
        UserDefaults.standard.sessionStoppedStatus = sessionStoppedStatus
        UserDefaults.standard.synchronize()
    }
    
    static func getSessionStoppedStatus() -> Bool? {
        return UserDefaults.standard.sessionStoppedStatus
    }
}
