//
//  RSLoggerPlugin.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

// MARK: - Plugin Implementation

class RSLoggerPlugin: RSUtilityPlugin {
    var logLevel = RSLogLevel.debug
    
    var client: RSClient? {
        didSet {
            addTargets()
        }
    }
    
    let type = PluginType.utility
    
    fileprivate var loggingMediator = [RSLoggingType: RSLogger]()
    
    // Default to no, enable to see local logs
    static var loggingEnabled = false
    
    // For use only. Note: This will contain the last created instance
    // of analytics when used in a multi-analytics environment.
    static var sharedAnalytics: RSClient?
    
    #if DEBUG
    static var globalLogger: RSLoggerPlugin {
        let logger = RSLoggerPlugin()
        logger.addTargets()
        return logger
    }
    #endif
    
    required init() { }
    
    func configure(client: RSClient) {
        self.client = client
        RSLoggerPlugin.sharedAnalytics = client
        addTargets()
    }
    
    func addTargets() {
        try? add(target: RSConsoleLogger(), for: RSLoggingType.log)
    }
    
    func loggingEnabled(_ enabled: Bool) {
        RSLoggerPlugin.loggingEnabled = enabled        
    }
    
    func log(_ logMessage: RSLogMessage, destination: RSLoggingType.LogDestination) {
        
        for (logType, target) in loggingMediator where logType.contains(destination) {
            target.parseLog(logMessage)
        }
    }
    
    func add(target: RSLogger, for loggingType: RSLoggingType) throws {
        
        // Verify the target does not exist, if it does bail out
        let filtered = loggingMediator.filter { (type: RSLoggingType, existingTarget: RSLogger) in
            Swift.type(of: existingTarget) == Swift.type(of: target)
        }
        if filtered.isEmpty == false { throw NSError(domain: "Target already exists", code: 2002, userInfo: nil) }
        
        // Finally add the target
        loggingMediator[loggingType] = target
    }    
}

// MARK: - Types

struct LogFactory {
    static func buildLog(destination: RSLoggingType.LogDestination,
                         title: String,
                         message: String,
                         logLevel: RSLogLevel = .debug,
                         function: String? = nil,
                         line: Int? = nil,
                         event: RSMessage? = nil,
                         sender: Any? = nil,
                         value: Double? = nil,
                         tags: [String]? = nil) -> RSLogMessage {
        
        switch destination {
        case .log:
            return GenericLog(logLevel: logLevel, message: message, function: function, line: line)
        case .metric:
            return MetricLog(title: title, message: message, value: value ?? 1, event: event, function: function, line: line)
        }
    }
    
    fileprivate struct GenericLog: RSLogMessage {
        var logLevel: RSLogLevel
        var title: String?
        var message: String
        var event: RSMessage?
        var function: String?
        var line: Int?
        var logType: RSLoggingType.LogDestination = .log
        var dateTime = Date()
    }
    
    fileprivate struct MetricLog: RSLogMessage {
        var title: String?
        var logLevel: RSLogLevel = .debug
        var message: String
        var value: Double
        var event: RSMessage?
        var function: String?
        var line: Int?
        var logType: RSLoggingType.LogDestination = .metric
        var dateTime = Date()
    }
}

extension RSClient {
    static func rsLog(message: String, logLevel: RSLogLevel? = nil, function: String = #function, line: Int = #line) {
        if let shared = RSLoggerPlugin.sharedAnalytics {
            shared.apply { plugin in
                if let loggerPlugin = plugin as? RSLoggerPlugin {
                    var filterKind = loggerPlugin.logLevel
                    if let logKind = logLevel {
                        filterKind = logKind
                    }
                    
                    let log = LogFactory.buildLog(destination: .log, title: "", message: message, logLevel: filterKind, function: function, line: line)
                    loggerPlugin.log(log, destination: .log)
                }
            }
        } else {
            #if DEBUG
            let log = LogFactory.buildLog(destination: .log, title: "", message: message, logLevel: .debug, function: function, line: line)
            RSLoggerPlugin.globalLogger.log(log, destination: .log)
            #endif
        }
    }
    
    static func rsMetric(_ type: RSMetricType, name: String, value: Double, tags: [String]? = nil) {
        RSLoggerPlugin.sharedAnalytics?.apply { plugin in
            
            if let loggerPlugin = plugin as? RSLoggerPlugin {
                let log = LogFactory.buildLog(destination: .metric, title: type.toString(), message: name, value: value, tags: tags)
                loggerPlugin.log(log, destination: .metric)
            }
        }
    }
}
