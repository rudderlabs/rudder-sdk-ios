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
    
    private var _dataPlaneUrl: String = RSDataPlaneUrl
    public var dataPlaneUrl: String {
        return _dataPlaneUrl
    }
    
    private var _flushQueueSize: Int = RSFlushQueueSize
    public var flushQueueSize: Int {
        return _flushQueueSize
    }
    
    private var _dbCountThreshold: Int = RSDBCountThreshold
    public var dbCountThreshold: Int {
        return _dbCountThreshold
    }
    
    private var _sleepTimeOut: Int = RSSleepTimeout
    public var sleepTimeOut: Int {
        return _sleepTimeOut
    }
    
    private var _logLevel: RSLogLevel = RSLogLevel.none
    public var logLevel: RSLogLevel {
        return _logLevel
    }
        
    private var _trackLifecycleEvents: Bool = RSTrackLifeCycleEvents
    public var trackLifecycleEvents: Bool {
        return _trackLifecycleEvents
    }
    
    private var _recordScreenViews: Bool = RSRecordScreenViews
    public var recordScreenViews: Bool {
        return _recordScreenViews
    }
    
    private var _controlPlaneUrl: String = RSControlPlaneUrl
    public var controlPlaneUrl: String {
        return _controlPlaneUrl
    }
    
    private var _autoSessionTracking: Bool = RSAutoSessionTracking
    public var automaticSessionTracking: Bool {
        return _autoSessionTracking
    }
    
    private var _sessionTimeout: Int = RSSessionTimeout
    public var sessionTimeout: Int {
        return _sessionTimeout
    }
    
    @objc
    public init(writeKey: String) {
        _writeKey = writeKey
    }
    
    @discardableResult @objc
    public func dataPlaneURL(_ dataPlaneUrl: String) -> RSConfig {
        if let url = URL(string: dataPlaneUrl) {
            if let scheme = url.scheme, let host = url.host {
                if let port = url.port {
                    _dataPlaneUrl = "\(scheme)://\(host):\(port)"
                } else {
                    _dataPlaneUrl = "\(scheme)://\(host)"
                }
            }
        }
        return self
    }
    
    @discardableResult @objc
    public func flushQueueSize(_ flushQueueSize: Int) -> RSConfig {
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
        _dbCountThreshold = dbCountThreshold
        return self
    }
    
    @discardableResult @objc
    public func sleepTimeOut(_ sleepTimeOut: Int) -> RSConfig {
        guard sleepTimeOut > 0 else {
            Logger.log(message: "sleepTimeOut can not be less than 1 second", logLevel: .warning)
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
        if let url = URL(string: controlPlaneUrl) {
            if let scheme = url.scheme, let host = url.host {
                if let port = url.port {
                    _controlPlaneUrl = "\(scheme)://\(host):\(port)"
                } else {
                    _controlPlaneUrl = "\(scheme)://\(host)"
                }
            }
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
        guard sessionTimeout >= RSSessionInActivityMinimumTimeOut else {
            Logger.log(message: "sessionTimeout can not be less than 0 second", logLevel: .warning)
            return self
        }
        _sessionTimeout = sessionTimeout
        return self
    }
}
