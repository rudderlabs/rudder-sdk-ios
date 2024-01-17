//
//  RSConfig.swift
//  RudderStack
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@frozen 
@objc
public enum RSDataResidencyServer: Int {
    case US
    case EU
}

@objc
open class RSConfig: NSObject {
    let _writeKey: String
    public var writeKey: String {
        return _writeKey
    }
    
    let _dataPlaneURL: String
    public var dataPlaneURL: String {
        return _dataPlaneURL
    }
    
    private var _flushQueueSize: Int = DEFAULT_FLUSH_QUEUE_SIZE
    public var flushQueueSize: Int {
        return _flushQueueSize
    }
    
    private var _dbCountThreshold: Int = DEFAULT_DB_COUNT_THRESHOLD
    public var dbCountThreshold: Int {
        return _dbCountThreshold
    }
    
    private var _sleepTimeOut: Int = DEFAULT_SLEEP_TIMEOUT
    public var sleepTimeOut: Int {
        return _sleepTimeOut
    }
    
    private var _logLevel: RSLogLevel = .error
    public var logLevel: RSLogLevel {
        return _logLevel
    }
        
    private var _trackLifecycleEvents: Bool = DEFAULT_TRACK_LIFE_CYCLE_EVENTS_STATUS
    public var trackLifecycleEvents: Bool {
        return _trackLifecycleEvents
    }
    
    private var _recordScreenViews: Bool = DEFAULT_RECORD_SCREEN_VIEWS_STATUS
    public var recordScreenViews: Bool {
        return _recordScreenViews
    }
    
    private var _controlPlaneURL: String = DEFAULT_CONTROL_PLANE_URL
    public var controlPlaneURL: String {
        return _controlPlaneURL
    }
    
    private var _autoSessionTracking: Bool = DEFAULT_AUTO_SESSION_TRACKING_STATUS
    public var automaticSessionTracking: Bool {
        return _autoSessionTracking
    }
    
    private var _sessionTimeout: Int = DEFAULT_SESSION_TIMEOUT
    public var sessionTimeout: Int {
        return _sessionTimeout
    }
    
    private var _gzipEnabled: Bool = DEFAULT_GZIP_ENABLED_STATUS
    public var gzipEnabled: Bool {
        return _gzipEnabled
    }
    
    private var _dataResidencyServer: RSDataResidencyServer = .US
    public var dataResidencyServer: RSDataResidencyServer {
        return _dataResidencyServer
    }
    
    private var _userDefaults: RSUserDefaults = RSUserDefaults()
    internal var userDefaults: RSUserDefaults {
        return _userDefaults
    }
    
    private var _downloadServerConfig: RSDownloadServerConfig?
    internal var downloadServerConfig: RSDownloadServerConfig? {
        return _downloadServerConfig
    }
    
    @objc
    public init(writeKey: String, dataPlaneURL: String) {
        _writeKey = writeKey
        if let url = URL(string: dataPlaneURL), url.isValid {
            _dataPlaneURL = url.absoluteString.rectified
        } else {
            Logger.logError("dataPlaneURL is invalid")
            _dataPlaneURL = ""
        }
    }
    
    @discardableResult @objc
    public func flushQueueSize(_ flushQueueSize: Int) -> RSConfig {
        guard flushQueueSize >= MIN_FLUSH_QUEUE_SIZE && flushQueueSize <= MAX_FLUSH_QUEUE_SIZE else {
            Logger.logError("flushQueueSize is out of range. Min: 1, Max: 100. Set to default")
            return self
        }
        _flushQueueSize = flushQueueSize
        return self
    }
        
    @discardableResult @objc
    public func loglevel(_ logLevel: RSLogLevel) -> RSConfig {
        _logLevel = logLevel
        return self
    }
    
    @discardableResult @objc
    public func dbCountThreshold(_ dbCountThreshold: Int) -> RSConfig {
        guard dbCountThreshold >= MIN_DB_COUNT_THRESHOLD else {
            Logger.logError("dbCountThreshold is invalid. Min: 1. Set to default")
            return self
        }
        _dbCountThreshold = dbCountThreshold
        return self
    }
    
    @discardableResult @objc
    public func sleepTimeOut(_ sleepTimeOut: Int) -> RSConfig {
        guard sleepTimeOut >= MIN_SLEEP_TIMEOUT else {
            Logger.logError("sleepTimeOut is invalid. Min: 10. Set to default")
            return self
        }
        _sleepTimeOut = sleepTimeOut
        return self
    }
        
    @discardableResult @objc
    public func trackLifecycleEvents(_ trackLifecycleEvents: Bool) -> RSConfig {
        _trackLifecycleEvents = trackLifecycleEvents
        return self
    }
    
    @discardableResult @objc
    public func recordScreenViews(_ recordScreenViews: Bool) -> RSConfig {
        _recordScreenViews = recordScreenViews
        return self
    }
    
    @discardableResult @objc
    public func controlPlaneURL(_ controlPlaneURL: String) -> RSConfig {
        guard let url = URL(string: controlPlaneURL), url.isValid else {
            Logger.logError("controlPlaneURL is invalid")
            return self
        }
        _controlPlaneURL = url.absoluteString.rectified
        return self
    }
    
    @discardableResult @objc
    public func autoSessionTracking(_ autoSessionTracking: Bool) -> RSConfig {
        _autoSessionTracking = autoSessionTracking
        return self
    }
    
    @discardableResult @objc
    public func sessionTimeout(_ sessionTimeout: Int) -> RSConfig {
        guard sessionTimeout >= MIN_SESSION_TIMEOUT else {
            Logger.logError("sessionTimeout is invalid. Min: 0. Set to default")
            return self
        }
        _sessionTimeout = sessionTimeout
        return self
    }
    
    @discardableResult @objc
    public func gzipEnabled(_ gzipEnabled: Bool) -> RSConfig {
        _gzipEnabled = gzipEnabled
        return self
    }
    
    @discardableResult @objc
    public func dataResidencyServer(_ dataResidencyServer: RSDataResidencyServer) -> RSConfig {
        _dataResidencyServer = dataResidencyServer
        return self
    }
    
    internal func userDefaults(_ userDefaults: RSUserDefaults) -> RSConfig {
        _userDefaults = userDefaults
        return self
    }
    
    internal func downloadServerConfig(_ downloadServerConfig: RSDownloadServerConfig) -> RSConfig {
        _downloadServerConfig = downloadServerConfig
        return self
    }
}

extension URL {
    var isValid: Bool {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return self.scheme != nil && self.host() != nil
        } else {
            return self.scheme != nil && self.host != nil
        }
    }
}

extension String {
    var rectified: String {
        if self.hasSuffix("/") {
            return self
        }
        return "\(self)/"
    }
}
