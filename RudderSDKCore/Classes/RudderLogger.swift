//
//  RudderLogger.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 09/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

class RudderLogger {
    private static var logLevel = RudderLogLevel.INFO;
    private static let TAG = "RudderSDK";
    
    init(_logLevel: Int) {
        if (_logLevel > RudderLogLevel.DEBUG) {
            RudderLogger.logLevel = RudderLogLevel.DEBUG;
        } else if (_logLevel < RudderLogLevel.NONE) {
            RudderLogger.logLevel = RudderLogLevel.NONE;
        } else {
            RudderLogger.logLevel = _logLevel;
        }
    }
    
    static func logError(message: String) {
        if (RudderLogger.logLevel >= RudderLogLevel.ERROR) {
            print(TAG + ":Error:" + message);
        }
    }
    
    static func logError(error: Error) {
        if (RudderLogger.logLevel >= RudderLogLevel.ERROR) {
            print(TAG + ":Error:")
            print(error);
        }
    }
    
    static func logWarn(message: String) {
        if (RudderLogger.logLevel >= RudderLogLevel.WARN) {
            print(TAG + ":Warn:" + message);
        }
    }
    
    static func logInfo(message: String) {
        if (RudderLogger.logLevel >= RudderLogLevel.INFO) {
            print(TAG + ":Info:" + message);
        }
    }
    
    static func logDebug(message: String) {
        if (RudderLogger.logLevel >= RudderLogLevel.DEBUG) {
            print(TAG + ":Debug:" + message);
        }
    }
}

class RudderLogLevel {
    static let DEBUG: Int = 4;
    static let INFO: Int = 3;
    static let WARN: Int = 2;
    static let ERROR: Int = 1;
    static let NONE: Int = 0;
}
