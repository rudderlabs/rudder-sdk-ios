//
//  ConsoleLoggerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 07/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class ConsoleLoggerTests: XCTestCase {
    let printFunctionMock = PrintFunctionMock()
    
    func test_debug() {
        // Given
        let consoleLogger = ConsoleLogger(logLevel: .debug, instanceName: "test", printFunction: printFunctionMock.print)
        
        // When
        consoleLogger.log("debug_message", logLevel: .debug)
        consoleLogger.log("error_message", logLevel: .error)
        consoleLogger.log("warning_message", logLevel: .warning)
        consoleLogger.log("info_message", logLevel: .info)
        
        // Then
        XCTAssertEqual(printFunctionMock.printedMessages.count, 1)
        XCTAssertEqual(printFunctionMock.printedMessage, "[RUDDERSTACK SDK] - DEBUG | [test] - ConsoleLoggerTests.swift:\(#function):20 | debug_message")
    }
    
    func test_error() {
        // Given
        let consoleLogger = ConsoleLogger(logLevel: .error, instanceName: "test", printFunction: printFunctionMock.print)
        
        // When
        consoleLogger.log("debug_message", logLevel: .debug)
        consoleLogger.log("error_message", logLevel: .error)
        consoleLogger.log("warning_message", logLevel: .warning)
        consoleLogger.log("info_message", logLevel: .info)
        
        // Then
        XCTAssertEqual(printFunctionMock.printedMessages.count, 1)
        XCTAssertEqual(printFunctionMock.printedMessages[0], "[RUDDERSTACK SDK] - ERROR | [test] - ConsoleLoggerTests.swift:\(#function):36 | error_message")
    }
    
    func test_warning() {
        // Given
        let consoleLogger = ConsoleLogger(logLevel: .warning, instanceName: "test", printFunction: printFunctionMock.print)
        
        // When
        consoleLogger.log("debug_message", logLevel: .debug)
        consoleLogger.log("error_message", logLevel: .error)
        consoleLogger.log("warning_message", logLevel: .warning)
        consoleLogger.log("info_message", logLevel: .info)
        
        // Then
        XCTAssertEqual(printFunctionMock.printedMessages.count, 1)
        XCTAssertEqual(printFunctionMock.printedMessages[0], "[RUDDERSTACK SDK] - WARN | [test] - ConsoleLoggerTests.swift:\(#function):52 | warning_message")
    }
    
    func test_info() {
        // Given
        let consoleLogger = ConsoleLogger(logLevel: .info, instanceName: "test", printFunction: printFunctionMock.print)
        
        // When
        consoleLogger.log("debug_message", logLevel: .debug)
        consoleLogger.log("error_message", logLevel: .error)
        consoleLogger.log("warning_message", logLevel: .warning)
        consoleLogger.log("info_message", logLevel: .info)
        
        // Then
        XCTAssertEqual(printFunctionMock.printedMessages.count, 1)
        XCTAssertEqual(printFunctionMock.printedMessages[0], "[RUDDERSTACK SDK] - INFO | [test] - ConsoleLoggerTests.swift:\(#function):68 | info_message")
    }
    
    func test_verbose() {
        // Given
        let consoleLogger = ConsoleLogger(logLevel: .verbose, instanceName: "test", printFunction: printFunctionMock.print)
        
        // When
        consoleLogger.log("debug_message", logLevel: .debug)
        consoleLogger.log("error_message", logLevel: .error)
        consoleLogger.log("warning_message", logLevel: .warning)
        consoleLogger.log("info_message", logLevel: .info)
        
        // Then
        XCTAssertEqual(printFunctionMock.printedMessages.count, 4)
        XCTAssertEqual(printFunctionMock.printedMessages[0], "[RUDDERSTACK SDK] - DEBUG | [test] - ConsoleLoggerTests.swift:\(#function):80 | debug_message")
        XCTAssertEqual(printFunctionMock.printedMessages[1], "[RUDDERSTACK SDK] - ERROR | [test] - ConsoleLoggerTests.swift:\(#function):81 | error_message")
        XCTAssertEqual(printFunctionMock.printedMessages[2], "[RUDDERSTACK SDK] - WARN | [test] - ConsoleLoggerTests.swift:\(#function):82 | warning_message")
        XCTAssertEqual(printFunctionMock.printedMessages[3], "[RUDDERSTACK SDK] - INFO | [test] - ConsoleLoggerTests.swift:\(#function):83 | info_message")
    }
    
    func test_none() {
        // Given
        let consoleLogger = ConsoleLogger(logLevel: .none, instanceName: "test", printFunction: printFunctionMock.print)
        
        // When
        consoleLogger.log("debug_message", logLevel: .debug)
        consoleLogger.log("error_message", logLevel: .error)
        consoleLogger.log("warning_message", logLevel: .warning)
        consoleLogger.log("info_message", logLevel: .info)
        
        // Then
        XCTAssertEqual(printFunctionMock.printedMessages.count, 0)
    }
}
