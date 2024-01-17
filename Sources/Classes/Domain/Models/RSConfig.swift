//
//  RSConfig.swift
//  RudderStack
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc
open class RSConfig: NSObject {
    let _writeKey: String
    public var writeKey: String {
        return _writeKey
    }
    
    private var _dataPlaneUrl: String = DEFAULT_DATA_PLANE_URL
    public var dataPlaneUrl: String {
        return _dataPlaneUrl
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
    
    private var _controlPlaneUrl: String = DEFAULT_CONTROL_PLANE_URL
    public var controlPlaneUrl: String {
        return _controlPlaneUrl
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
    
    @objc
    public init(writeKey: String) {
        _writeKey = writeKey
    }
    
    @discardableResult @objc
    public func dataPlaneURL(_ dataPlaneUrl: String) -> RSConfig {
        guard let url = URL(string: dataPlaneUrl), let scheme = url.scheme, let host = url.host else {
            Logger.logError("dataPlaneUrl is invalid")
            return self
        }
        if let port = url.port {
            _dataPlaneUrl = "\(scheme)://\(host):\(port)"
        } else {
            _dataPlaneUrl = "\(scheme)://\(host)"
        }
        return self
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
    public func controlPlaneURL(_ controlPlaneUrl: String) -> RSConfig {
        guard let url = URL(string: controlPlaneUrl), let scheme = url.scheme, let host = url.host else {
            Logger.logError("controlPlaneUrl is invalid")
            return self
        }
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            _controlPlaneUrl = "\(scheme)://\(host)\(url.path())"
        } else {
            _controlPlaneUrl = "\(scheme)://\(host)\(url.path)"
        }
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
}
