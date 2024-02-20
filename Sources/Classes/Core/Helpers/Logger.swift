//
//  Logger.swift
//  Rudder
//
//  Created by Pallab Maiti on 27/11/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@frozen
@objc(RSLogLevel)
public enum LogLevel: Int {
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

public protocol LoggerProtocol {
    func logDebug(_ message: String, file: String, function: String, line: Int)
    func logInfo(_ message: String, file: String, function: String, line: Int)
    func logWarning(_ message: String, file: String, function: String, line: Int)
    func logError(_ message: String, file: String, function: String, line: Int)
}

class Logger {
    let logger: LoggerProtocol
    
    init(logger: LoggerProtocol) {
        self.logger = logger
    }
    
    func logDebug(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.logDebug(message.description, file: file, function: function, line: line)
    }
    
    func logInfo(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.logInfo(message.description, file: file, function: function, line: line)
    }
    
    func logWarning(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.logWarning(message.description, file: file, function: function, line: line)
    }
    
    func logError(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.logError(message.description, file: file, function: function, line: line)
    }
}

class ConsoleLogger: LoggerProtocol {
    let logLevel: LogLevel
    
    init(logLevel: LogLevel = .error) {
        self.logLevel = logLevel
    }
    
    func logDebug(_ message: String, file: String, function: String, line: Int) {
        log(message: message, logLevel: .debug, file: file, function: function, line: line)
    }
    
    func logInfo(_ message: String, file: String, function: String, line: Int) {
        log(message: message, logLevel: .info, file: file, function: function, line: line)
    }
    
    func logWarning(_ message: String, file: String, function: String, line: Int) {
        log(message: message, logLevel: .warning, file: file, function: function, line: line)
    }
    
    func logError(_ message: String, file: String, function: String, line: Int) {
        log(message: message, logLevel: .error, file: file, function: function, line: line)
    }

    private func log(message: String, logLevel: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        if logLevel == .verbose || logLevel == self.logLevel {
            let metadata = " - \(((file as NSString).lastPathComponent as NSString).deletingPathExtension):\(function):\(line):"
            print("RudderStack:\(logLevel.toString()):\(metadata)\(message)")
        }
    }
}

extension RSClient: LoggerProtocol {
    public func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        controller.logger.logDebug(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    public func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        controller.logger.logInfo(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    public func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        controller.logger.logWarning(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
    
    public func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        controller.logger.logError(LogMessages.customMessage(message), file: file, function: function, line: line)
    }
}
