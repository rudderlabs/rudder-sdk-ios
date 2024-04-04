//
//  Config.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public enum DataResidencyServer {
    case US
    case EU
}

enum ConfigValidationError: Error {
    case flushQueueSize
    case dbCountThreshold
    case sleepTimeOut
    case controlPlaneURL
    case sessionTimeOut
    
    var description: String {
        switch self {
        case .flushQueueSize:
            return "flushQueueSize is out of range. Min: 1, Max: 100. Set to default"
        case .dbCountThreshold:
            return "dbCountThreshold is invalid. Min: 1. Set to default"
        case .sleepTimeOut:
            return "sleepTimeOut is invalid. Min: 10. Set to default"
        case .controlPlaneURL:
            return "controlPlaneURL is invalid"
        case .sessionTimeOut:
            return "sessionTimeout is invalid. Min: 0. Set to default"
        }
    }
}

public class Configuration {
    let _writeKey: String
    public var writeKey: String {
        return _writeKey
    }
    
    let _dataPlaneURL: String
    public var dataPlaneURL: String {
        return _dataPlaneURL
    }
    
    private var _flushQueueSize: Int = Constants.queueSize.default
    public var flushQueueSize: Int {
        return _flushQueueSize
    }
    
    private var _dbCountThreshold: Int = Constants.storageCountThreshold.default
    public var dbCountThreshold: Int {
        return _dbCountThreshold
    }
    
    private var _sleepTimeOut: Int = Constants.sleepTimeOut.default
    public var sleepTimeOut: Int {
        return _sleepTimeOut
    }
    
    private var _logLevel: LogLevel = .error
    public var logLevel: LogLevel {
        return _logLevel
    }
        
    private var _trackLifecycleEvents: Bool = Constants.trackLifeCycleEvent.default
    public var trackLifecycleEvents: Bool {
        return _trackLifecycleEvents
    }
        
    private var _controlPlaneURL: String = Constants.controlPlaneUrl.default
    public var controlPlaneURL: String {
        return _controlPlaneURL
    }
    
    private var _autoSessionTracking: Bool = Constants.autoSessionTracking.default
    public var automaticSessionTracking: Bool {
        return _autoSessionTracking
    }
    
    private var _sessionTimeOut: Int = Constants.sessionTimeOut.default
    public var sessionTimeOut: Int {
        return _sessionTimeOut
    }
    
    private var _gzipEnabled: Bool = Constants.gzipEnabled.default
    public var gzipEnabled: Bool {
        return _gzipEnabled
    }
    
    private var _flushPolicies = [FlushPolicy]()
    public var flushPolicies: [FlushPolicy] {
        _flushPolicies
    }
    
    private var _dataUploadRetryPolicy: RetryPolicy?
    public var dataUploadRetryPolicy: RetryPolicy? {
        _dataUploadRetryPolicy
    }
    
    private var _sourceConfigDownloadRetryPolicy: RetryPolicy?
    public var sourceConfigDownloadRetryPolicy: RetryPolicy? {
        _sourceConfigDownloadRetryPolicy
    }
    
    private var _logger: LoggerProtocol?
    public var logger: LoggerProtocol? {
        _logger
    }
    
    var configValidationErrorList = [ConfigValidationError]()
    
    required public init?(writeKey: String, dataPlaneURL: String) {
        guard writeKey.isNotEmpty, let url = URL(string: dataPlaneURL), url.isValid else {
            return nil
        }
        _writeKey = writeKey
        _dataPlaneURL = dataPlaneURL.rectified
    }
    
    @discardableResult
    public func flushQueueSize(_ flushQueueSize: Int) -> Configuration {
        guard flushQueueSize >= Constants.queueSize.min && flushQueueSize <= Constants.queueSize.max else {
            configValidationErrorList.append(.flushQueueSize)
            return self
        }
        _flushQueueSize = flushQueueSize
        return self
    }
        
    @discardableResult
    public func logLevel(_ logLevel: LogLevel) -> Configuration {
        _logLevel = logLevel
        return self
    }
    
    @discardableResult
    public func dbCountThreshold(_ dbCountThreshold: Int) -> Configuration {
        guard dbCountThreshold >= Constants.storageCountThreshold.min else {
            configValidationErrorList.append(.dbCountThreshold)
            return self
        }
        _dbCountThreshold = dbCountThreshold
        return self
    }
    
    @discardableResult
    public func sleepTimeOut(_ sleepTimeOut: Int) -> Configuration {
        guard sleepTimeOut >= Constants.sleepTimeOut.min else {
            configValidationErrorList.append(.sleepTimeOut)
            return self
        }
        _sleepTimeOut = sleepTimeOut
        return self
    }
        
    @discardableResult
    public func trackLifecycleEvents(_ trackLifecycleEvents: Bool) -> Configuration {
        _trackLifecycleEvents = trackLifecycleEvents
        return self
    }
        
    @discardableResult
    public func controlPlaneURL(_ controlPlaneURL: String) -> Configuration {
        guard let url = URL(string: controlPlaneURL), url.isValid else {
            configValidationErrorList.append(.controlPlaneURL)
            return self
        }
        _controlPlaneURL = url.absoluteString.rectified
        return self
    }
    
    @discardableResult
    public func autoSessionTracking(_ autoSessionTracking: Bool) -> Configuration {
        _autoSessionTracking = autoSessionTracking
        return self
    }
    
    @discardableResult
    public func sessionTimeOut(_ sessionTimeOut: Int) -> Configuration {
        guard sessionTimeOut >= Constants.sessionTimeOut.min else {
            configValidationErrorList.append(.sessionTimeOut)
            return self
        }
        _sessionTimeOut = sessionTimeOut
        return self
    }
    
    @discardableResult
    public func gzipEnabled(_ gzipEnabled: Bool) -> Configuration {
        _gzipEnabled = gzipEnabled
        return self
    }
    
    @discardableResult
    public func dataResidencyServer(_ dataResidencyServer: DataResidencyServer) -> Configuration {
        _dataResidencyServer = dataResidencyServer
        return self
    }
    
    @discardableResult
    public func flushPolicies(_ flushPolicies: [FlushPolicy]) -> Configuration {
        if !flushPolicies.isEmpty {
            _flushPolicies.append(contentsOf: flushPolicies)
        }
        return self
    }
    
    @discardableResult
    public func dataUploadRetryPolicy(_ dataUploadRetryPolicy: RetryPolicy?) -> Configuration {
        _dataUploadRetryPolicy = dataUploadRetryPolicy
        return self
    }
    
    @discardableResult
    public func sourceConfigDownloadRetryPolicy(_ sourceConfigDownloadRetryPolicy: RetryPolicy?) -> Configuration {
        _sourceConfigDownloadRetryPolicy = sourceConfigDownloadRetryPolicy
        return self
    }
    
    @discardableResult
    public func logger(_ logger: LoggerProtocol?) -> Configuration {
        _logger = logger
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
