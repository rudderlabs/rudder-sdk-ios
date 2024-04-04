//
//  ConsoleLoggerMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 07/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import Rudder

class ConsoleLoggerMock: LoggerProtocol {
    let logLevel: LogLevel
    var logMessage: String = ""
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    func log(_ message: String, logLevel: Rudder.LogLevel, file: String, function: String, line: Int) {
        if self.logLevel == .verbose || self.logLevel == logLevel {
            logMessage = message
        } else {
            logMessage = ""
        }
    }
}
