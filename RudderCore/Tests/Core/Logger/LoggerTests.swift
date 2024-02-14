//
//  LoggerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 07/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class LoggerTests: XCTestCase {
    func test_debug() {        
        // Given
        let consoleLogger = ConsoleLoggerMock(logLevel: .debug)
        let logger = Logger(logger: consoleLogger)
        
        // When & Then
        logger.logDebug(LogMessages.customMessage("test_message"))
        XCTAssertEqual(consoleLogger.logMessage, "test_message")
        
        logger.logDebug("test_message_2")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_2")
        
        logger.logError("test_message_3")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logWarning("test_message_4")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logInfo("test_message_5")
        XCTAssertEqual(consoleLogger.logMessage, "")
    }
    
    func test_error() {
        // Given
        let consoleLogger = ConsoleLoggerMock(logLevel: .error)
        let logger = Logger(logger: consoleLogger)
        
        // When & Then
        logger.logDebug("test_message")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logError(LogMessages.customMessage("test_message_2"))
        XCTAssertEqual(consoleLogger.logMessage, "test_message_2")
        
        logger.logError("test_message_3")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_3")
        
        logger.logWarning("test_message_4")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logInfo("test_message_5")
        XCTAssertEqual(consoleLogger.logMessage, "")
    }
    
    func test_warning() {
        // Given
        let consoleLogger = ConsoleLoggerMock(logLevel: .warning)
        let logger = Logger(logger: consoleLogger)
        
        logger.logDebug("test_message")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logError("test_message_2")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logWarning(.customMessage("test_message_3"))
        XCTAssertEqual(consoleLogger.logMessage, "test_message_3")
        
        logger.logWarning("test_message_4")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_4")
        
        logger.logInfo("test_message_5")
        XCTAssertEqual(consoleLogger.logMessage, "")
    }
    
    func test_info() {
        // Given
        let consoleLogger = ConsoleLoggerMock(logLevel: .info)
        let logger = Logger(logger: consoleLogger)
        
        // When & Then
        logger.logDebug("test_message")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logError("test_message_2")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logWarning("test_message_3")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logInfo(LogMessages.customMessage("test_message_4"))
        XCTAssertEqual(consoleLogger.logMessage, "test_message_4")
        
        logger.logInfo("test_message_5")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_5")
    }
    
    func test_verbose() {
        // Given
        let consoleLogger = ConsoleLoggerMock(logLevel: .verbose)
        let logger = Logger(logger: consoleLogger)
        
        // When & Then
        logger.logDebug("test_message_2")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_2")
        
        logger.logError("test_message_3")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_3")
        
        logger.logWarning("test_message_4")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_4")
        
        logger.logInfo("test_message_5")
        XCTAssertEqual(consoleLogger.logMessage, "test_message_5")
    }
    
    func test_none() {
        // Given
        let consoleLogger = ConsoleLoggerMock(logLevel: .none)
        let logger = Logger(logger: consoleLogger)
        
        // When & Then
        logger.logDebug("test_message_2")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logError("test_message_3")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logWarning("test_message_4")
        XCTAssertEqual(consoleLogger.logMessage, "")
        
        logger.logInfo("test_message_5")
        XCTAssertEqual(consoleLogger.logMessage, "")
    }
}
