//
//  FlushPolicyTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 13/02/24.
//

import XCTest
@testable import Rudder

final class FlushPolicyTests: XCTestCase {
    func test_shouldFlush() {
        // Given
        let flushQueueSize: Int = .mockRandom(min: 5, max: 30)
        let flushPolicy = CountBasedFlushPolicy(flushQueueSize: flushQueueSize)
        
        XCTAssertFalse(flushPolicy.shouldFlush())
        
        // When
        for _ in 0..<flushQueueSize {
            flushPolicy.updateState()
        }
        
        // Then
        XCTAssertTrue(flushPolicy.shouldFlush())
    }
    
    func test_reset() {
        // Given
        let flushQueueSize: Int = .mockRandom(min: 5, max: 30)
        let flushPolicy = CountBasedFlushPolicy(flushQueueSize: flushQueueSize)
        
        for _ in 0..<flushQueueSize {
            flushPolicy.updateState()
        }
                
        XCTAssertTrue(flushPolicy.shouldFlush())
        
        // When
        flushPolicy.reset()
        
        // Then
        XCTAssertFalse(flushPolicy.shouldFlush())
    }
}
