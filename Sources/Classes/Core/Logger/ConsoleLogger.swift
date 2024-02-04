//
//  ConsoleLogger.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol LoggerProtocol {
    func log(_ message: String, logLevel: LogLevel, file: String, function: String, line: Int)
}

/// Function printing `String` content to console.
var consolePrint: (String) -> Void = { print($0) }

class ConsoleLogger: LoggerProtocol {
    private let logLevel: LogLevel
    private let instanceName: String
    private let printFunction: (String) -> Void
    
    init(logLevel: LogLevel, instanceName: String, printFunction: @escaping (String) -> Void = consolePrint) {
        self.logLevel = logLevel
        self.instanceName = instanceName
        self.printFunction = printFunction
    }
    
    func log(_ message: String, logLevel: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        if self.logLevel == .verbose || self.logLevel == logLevel {
            let fileName = (file as NSString).lastPathComponent
            let log = "[RUDDERSTACK SDK] - \(logLevel.tag) | [\(instanceName)] - \(fileName):\(function):\(line) | \(message)"
            printFunction(log)
        }
    }
}
