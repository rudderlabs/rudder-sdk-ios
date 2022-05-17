//
//  RSLogger.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol RSLogger {
    func parseLog(_ log: RSLogMessage)
}

public struct RSLoggingType: Hashable {
    
    public enum LogDestination {
        case log
        case metric
    }
    
    public static let log = RSLoggingType(types: [.log])
    public static let metric = RSLoggingType(types: [.metric])
    
    init(types: [LogDestination]) {
        self.allTypes = types
    }
    
    private let allTypes: [LogDestination]
    func contains(_ destination: LogDestination) -> Bool {
        return allTypes.contains(destination)
    }
}

public protocol RSLogMessage {
    var logLevel: RSLogLevel { get }
    var title: String? { get }
    var message: String { get }
    var event: RSMessage? { get }
    var function: String? { get }
    var line: Int? { get }
    var logType: RSLoggingType.LogDestination { get }
    var dateTime: Date { get }
}

public enum RSMetricType: Int {
    case counter = 0    // Not Verbose
    case gauge          // Semi-verbose
    
    func toString() -> String {
        var typeString = "Gauge"
        if self == .counter {
            typeString = "Counter"
        }
        return typeString
    }
    
    static func fromString(_ string: String) -> Self {
        var returnType = Self.counter
        if string == "Gauge" {
            returnType = .gauge
        }
        
        return returnType
    }
}

// MARK: - Logging API

extension RSClient {
    
    /// The logging method for capturing all general types of log messages related to RudderStack.
    /// - Parameters:
    ///   - message: The main message of the log to be captured.
    ///   - logLevel: Usually .error, .warning or .debug, in order of serverity. This helps filter logs based on this added metadata.
    ///   - function: The name of the function the log came from. This will be captured automatically.
    ///   - line: The line number in the function the log came from. This will be captured automatically.
    public func log(message: String, logLevel: RSLogLevel? = nil, function: String = #function, line: Int = #line) {
        apply { plugin in
            // Check if we should send off the event
            if RSLoggerPlugin.loggingEnabled == false {
                return
            }
            if let loggerPlugin = plugin as? RSLoggerPlugin {
                var filterKind = loggerPlugin.logLevel
                if let logKind = logLevel {
                    filterKind = logKind
                }
                
                let log = LogFactory.buildLog(destination: .log, title: "", message: message, logLevel: filterKind, function: function, line: line)
                loggerPlugin.log(log, destination: .log)
            }
        }
    }
    
    /// The logging method for capturing metrics related to RudderStack or other libraries.
    /// - Parameters:
    ///   - type: Metric type, usually .counter or .gauge. Select the one that makes sense for the metric.
    ///   - name: The title of the metric to track.
    ///   - value: The value associated with the metric. This would be an incrementing counter or time or pressure gauge.
    ///   - tags: Any tags that should be associated with the metric. Any extra metadata that may help.
    public func metric(_ type: RSMetricType, name: String, value: Double, tags: [String]? = nil) {
        apply { plugin in
            // Check if we should send off the event
            if RSLoggerPlugin.loggingEnabled == false {
                return
            }
            
            if let loggerPlugin = plugin as? RSLoggerPlugin {
                
                let log = LogFactory.buildLog(destination: .metric, title: type.toString(), message: name, value: value, tags: tags)
                loggerPlugin.log(log, destination: .metric)
            }
        }
    }
}

extension RSClient {
    /// Add a logging target to the system. These `targets` can handle logs in various ways. Consider
    /// sending logs to the console, the OS and a web service. Three targets can handle these scenarios.
    /// - Parameters:
    ///   - target: A `LogTarget` that has logic to parse and handle log messages.
    ///   - type: The type consists of `log`, `metric` or `history`. These correspond to the
    ///   public API on Analytics.
    public func add(target: RSLogger, type: RSLoggingType) {
        apply { (potentialLogger) in
            if let logger = potentialLogger as? RSLoggerPlugin {
                do {
                    try logger.add(target: target, for: type)
                } catch {
                    Self.rsLog(message: "Could not add target: \(error.localizedDescription)", logLevel: .error)
                }
            }
        }
    }
}
