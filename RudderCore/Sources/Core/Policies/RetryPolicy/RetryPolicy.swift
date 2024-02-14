//
//  RetryPolicy.swift
//  Rudder
//
//  Created by Pallab Maiti on 20/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol RetryPolicy {
    var retryPreset: RetryPreset { get }
    var current: TimeInterval { get }
    func increase()
    func reset()
    func shouldRetry() -> Bool
}

struct RetryFactors {
    let retryPreset: RetryPreset
    let current: TimeInterval
}

class ExponentialRetryPolicy: RetryPolicy {
    var retryPreset: RetryPreset
    var current: TimeInterval
    private var retryFactors: RetryFactors
    private var collision: Int = 0
    
    init(retryFactors: RetryFactors) {
        self.retryFactors = retryFactors
        self.retryPreset = retryFactors.retryPreset
        self.current = retryFactors.current
    }
    
    func increase() {
        let calculate = (pow(Double(retryPreset.factor), Double(collision)) - 1.0) / 2.0
        current = min(current + calculate, retryPreset.maxTimeout)
        collision += 1
    }
    
    func reset() {
        collision = 0
        current = retryFactors.current
    }
    
    func shouldRetry() -> Bool {
        collision != retryPreset.retries
    }
}
