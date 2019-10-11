//
//  RudderConfig.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 09/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

open class RudderConfig {
    private var endpointUrl: String
    private var flushQueueSize: Int32
    private var dbCountThreshold: Int32
    private var sleepTimeout: Int32
    private var logLevel: Int
    private var factories: [RudderIntegration<Any>.Factory]
    
    init() {
        self.endpointUrl = Constants.BASE_URL
        self.flushQueueSize = Constants.FLUSH_QUEUE_SIZE
        self.dbCountThreshold = Constants.DB_COUNT_THRESHOLD
        self.sleepTimeout = Constants.SLEEP_TIME_OUT
        self.logLevel = RudderLogLevel.INFO
        self.factories = []
    }
    
    init(_endPointUrl: String, _flushQueueSize: Int32, _dbCountThreshold: Int32, _sleepTimeout: Int32, _logLevel: Int, _factories: [RudderIntegration<Any>.Factory]) {
        if (_endPointUrl.isEmpty) {
            RudderLogger.logError(message: "endPointUri can not be empty. Set to default.");
            self.endpointUrl = Constants.BASE_URL
        } else {
            self.endpointUrl = _endPointUrl
        }
        
        if (_flushQueueSize < 1 || _flushQueueSize > 100) {
            RudderLogger.logError(message: "flushQueueSize is out of range. Min: 1, Max: 100. Set to default");
            self.flushQueueSize = Constants.FLUSH_QUEUE_SIZE
        } else {
            self.flushQueueSize = _flushQueueSize
        }

        if (_dbCountThreshold < 0) {
            RudderLogger.logError(message: "invalid dbCountThreshold")
            self.dbCountThreshold = Constants.DB_COUNT_THRESHOLD
        } else {
            self.dbCountThreshold = _dbCountThreshold
        }
        
        if (_sleepTimeout < 10) {
            RudderLogger.logError(message: "invalid sleepTimeOut")
            self.sleepTimeout = Constants.SLEEP_TIME_OUT
        } else {
            self.sleepTimeout = _sleepTimeout
        }
        
        self.logLevel = _logLevel
        
        if (!_factories.isEmpty) {
            self.factories = _factories
        } else {
            self.factories = []
        }
    }
    
    public func getEndPointUrl() -> String {
        return self.endpointUrl
    }
    
    public func getFlushQueueSize() -> Int32 {
        return self.flushQueueSize
    }
    
    public func getDbCountThreshold() -> Int32 {
        return self.dbCountThreshold
    }
    
    public func getSleepTimeOut() -> Int32 {
        return self.sleepTimeout
    }
    
    public func getLogLevel() -> Int {
        return self.logLevel
    }
 
    public func getFactories() -> [RudderIntegration<Any>.Factory] {
        return self.factories
    }
    
    public class Builder {
        public init() {
            
        }
        
        private var factories: [RudderIntegration<Any>.Factory] = []
        
        public func withFactory(integration: RudderIntegration<Any>.Factory) -> Builder {
            self.factories.append(integration)
            return self
        }
        
        public func withFactories(integrations: [RudderIntegration<Any>.Factory]) -> Builder {
            self.factories.append(contentsOf: integrations)
            return self
        }
        
        private var endPointUrl: String = Constants.BASE_URL
        
        public func withEndPointUrl(endPointUrl: String) -> Builder {
            self.endPointUrl = endPointUrl
            return self
        }
        
        private var flushQueueSize: Int32 = Constants.FLUSH_QUEUE_SIZE
        
        public func withFlushQueueSize(flushQueueSize: Int32) -> Builder {
            self.flushQueueSize = flushQueueSize
            return self
        }
        
        private var logLevel: Int = RudderLogLevel.INFO
        
        public func withDebug(isDebug: Bool) -> Builder {
            if (isDebug) {
                self.logLevel = RudderLogLevel.DEBUG
            } else {
                self.logLevel = RudderLogLevel.ERROR
            }
            return self
        }
        
        public func withLogLevel(logLevel: Int) -> Builder {
            self.logLevel = logLevel
            return self
        }
        
        private var dbCountThreshold: Int32 = Constants.DB_COUNT_THRESHOLD
        
        public func withDbCountThreshold(dbCountThreshold: Int32) -> Builder {
            self.dbCountThreshold = dbCountThreshold
            return self
        }
        
        private var sleepTimeOut: Int32 = Constants.SLEEP_TIME_OUT
        
        public func withSleepTimeout(sleepTimeOut: Int32) -> Builder {
            self.sleepTimeOut = sleepTimeOut
            return self
        }
        
        public func build() -> RudderConfig {
            return RudderConfig(_endPointUrl: self.endPointUrl, _flushQueueSize: self.flushQueueSize, _dbCountThreshold: self.dbCountThreshold, _sleepTimeout: self.sleepTimeOut, _logLevel: self.logLevel, _factories: self.factories)
        }
    }
}
