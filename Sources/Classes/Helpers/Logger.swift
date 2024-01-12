//
//  Logger.swift
//  Rudder
//
//  Created by Pallab Maiti on 27/11/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@frozen @objc public enum RSLogLevel: Int {
    case verbose = 5
    case debug = 4
    case info = 3
    case warning = 2
    case error = 1
    case none = 0
    
    public func toString() -> String {
        switch self {
        case .verbose:
            return "Verbose"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .none:
            return ""
        }
    }
}

class Logger {
    static var logLevel: RSLogLevel = .error

    static func logDebug(_ message: String?, function: String = #function, line: Int = #line) {
        log(message: message, logLevel: .debug, function: function, line: line)
    }
    
    static func logInfo(_ message: String?, function: String = #function, line: Int = #line) {
        log(message: message, logLevel: .info, function: function, line: line)
    }
    
    static func logWarning(_ message: String?, function: String = #function, line: Int = #line) {
        log(message: message, logLevel: .warning, function: function, line: line)
    }
    
    static func logError(_ message: String?, function: String = #function, line: Int = #line) {
        log(message: message, logLevel: .error, function: function, line: line)
    }

    static func log(message: String?, logLevel: RSLogLevel, function: String = #function, line: Int = #line) {
        if let message = message, self.logLevel == .verbose || self.logLevel == logLevel {
            let metadata = " - \(function):\(line):"
            print("RudderStack:\(logLevel.toString()):\(metadata)\(message)")
        }
    }
}

extension RSClient {
    public func log(message: String?, logLevel: RSLogLevel) {
        Logger.log(message: message, logLevel: logLevel)
    }
}
