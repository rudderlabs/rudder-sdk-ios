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
    let logLevel: RSLogLevel
    let instanceName: String
    
    init(instanceName: String, logLevel: RSLogLevel = .error) {
        self.instanceName = instanceName
        self.logLevel = logLevel
    }

    func logDebug(_ message: String, function: String = #function, line: Int = #line, file: String = #file) {
        log(message: message, logLevel: .debug, function: function, line: line, file: file)
    }
    
    func logInfo(_ message: String, function: String = #function, line: Int = #line, file: String = #file) {
        log(message: message, logLevel: .info, function: function, line: line, file: file)
    }
    
    func logWarning(_ message: String, function: String = #function, line: Int = #line, file: String = #file) {
        log(message: message, logLevel: .warning, function: function, line: line, file: file)
    }
    
    func logError(_ message: String, function: String = #function, line: Int = #line, file: String = #file) {
        log(message: message, logLevel: .error, function: function, line: line, file: file)
    }

    func log(message: String, logLevel: RSLogLevel, function: String = #function, line: Int = #line, file: String = #file) {
        if self.logLevel == .verbose || self.logLevel == logLevel {
            let metadata = " - \(function):\(line):"
            if let filePath = URL(string: file) {
                print("RudderStack:\(instanceName):\(logLevel.toString()):\(filePath.lastPathComponent):\(metadata)\(message)")
            } else {
                print("RudderStack:\(instanceName):\(logLevel.toString()):\(metadata)\(message)")
            }
        }
    }
}

extension RSClient {
    public func log(message: String, logLevel: RSLogLevel) {
        logger.log(message: message, logLevel: logLevel)
    }
}
