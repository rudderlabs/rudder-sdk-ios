//
//  RetryPreset.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol RetryPreset {
    var retries: Int { get }
    var maxTimeout: TimeInterval { get }
    var minTimeout: TimeInterval { get }
    var factor: Int { get }
}

struct DownloadUploadRetryPreset: RetryPreset {
    var retries: Int
    var maxTimeout: TimeInterval
    var minTimeout: TimeInterval
    var factor: Int
    
    init(retries: Int, maxTimeout: TimeInterval, minTimeout: TimeInterval, factor: Int) {
        self.retries = retries
        self.maxTimeout = maxTimeout
        self.minTimeout = minTimeout
        self.factor = factor
    }
}

extension DownloadUploadRetryPreset {
    static func defaultDownload() -> Self {
        .init(retries: 3, maxTimeout: TimeInterval(60), minTimeout: TimeInterval(1), factor: 2)
    }
    
    static func defaultUpload(minTimeout: TimeInterval) -> Self {
        .init(retries: 100, maxTimeout: TimeInterval(300), minTimeout: minTimeout, factor: 2)
    }
}
