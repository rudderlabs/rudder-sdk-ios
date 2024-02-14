//
//  RetryPolicyTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 26/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class RetryPolicyTests: XCTestCase {
    
    let retryFactors: RetryFactors = .mockWith(
        retryPreset: DownloadUploadRetryPreset.mockWith(
            retries: .mockRandom(min: 2, max: 5),
            maxTimeout: TimeInterval(60),
            minTimeout: TimeInterval(5),
            factor: 2
        ),
        current: TimeInterval(0)
    )
    
    func test_increase() {
        let retry = ExponentialRetryPolicy(retryFactors: retryFactors)
        var previousValue: TimeInterval = retry.current
        
        var collision = 0
        while previousValue < retryFactors.retryPreset.maxTimeout {
            retry.increase()
            
            let nextValue = retry.current
            
            XCTAssertEqual(
                nextValue - previousValue,
                (pow(Double(retryFactors.retryPreset.factor), Double(collision)) - 1.0) / 2.0
            )
            XCTAssertGreaterThanOrEqual(nextValue, min(previousValue, retryFactors.retryPreset.maxTimeout))
            previousValue = nextValue
            collision += 1
        }
    }
    
    func test_reset() {
        // Given
        let retry = ExponentialRetryPolicy(retryFactors: retryFactors)
        for _ in 0..<3 {
            retry.increase()
        }
        XCTAssertEqual(retry.current, 2)
        
        // When
        retry.reset()
        
        // Then
        XCTAssertEqual(retry.current, retryFactors.current)
    }
    
    func test_shouldRetry() {
        let retry = ExponentialRetryPolicy(retryFactors: retryFactors)
        var previousValue: TimeInterval = retry.current
        
        var collision = 0
        while previousValue < retryFactors.retryPreset.maxTimeout {
            retry.increase()
            let nextValue = retry.current
            previousValue = nextValue
            collision += 1
        }
        
        if collision == retryFactors.retryPreset.retries {
            XCTAssertFalse(retry.shouldRetry())
        } else {
            XCTAssertTrue(retry.shouldRetry())
        }
    }
}
