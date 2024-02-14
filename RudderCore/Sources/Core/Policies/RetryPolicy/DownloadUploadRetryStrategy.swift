//
//  DownloadUploadRetryStrategy.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public struct RetryStrategy {
    let retryPreset: RetryPreset?
    let retryPolicy: RetryPolicy?
}

class DownloadUploadRetryStrategy {
    let retryPolicy: RetryPolicy
    
    init(retryPolicy: RetryPolicy) {
        self.retryPolicy = retryPolicy
    }
    
    var current: TimeInterval {
        retryPolicy.current
    }
    
    var retries: Int {
        retryPolicy.retryPreset.retries
    }
    
    func increase() {
        retryPolicy.increase()
    }
    
    func reset() {
        retryPolicy.reset()
    }
    
    func shouldRetry() -> Bool {
        retryPolicy.shouldRetry()
    }
}
