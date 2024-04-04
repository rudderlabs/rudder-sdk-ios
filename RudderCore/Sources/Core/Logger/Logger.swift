//
//  Logger.swift
//  Rudder
//
//  Created by Pallab Maiti on 27/11/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public class Logger {
    let logger: LoggerProtocol
    
    init(logger: LoggerProtocol) {
        self.logger = logger
    }
    
    func logDebug(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message.description, logLevel: .debug, file: file, function: function, line: line)
    }
    
    func logInfo(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message.description, logLevel: .info, file: file, function: function, line: line)
    }
    
    func logWarning(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message.description, logLevel: .warning, file: file, function: function, line: line)
    }
    
    func logError(_ message: LogMessages, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message.description, logLevel: .error, file: file, function: function, line: line)
    }
}

public extension Logger {
    func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message, logLevel: .debug, file: file, function: function, line: line)
    }
    
    func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message, logLevel: .info, file: file, function: function, line: line)
    }
    
    func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message, logLevel: .warning, file: file, function: function, line: line)
    }
    
    func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.log(message, logLevel: .error, file: file, function: function, line: line)
    }
}
