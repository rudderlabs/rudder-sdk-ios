//
//  CountBasedFlushPolicy.swift
//  Rudder
//
//  Created by Pallab Maiti on 17/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol FlushPolicy {
    func updateState()
    func reset()
    func shouldFlush() -> Bool
}

class CountBasedFlushPolicy: FlushPolicy {
    let config: Configuration
    
    @ReadWriteLock
    var count = 0

    init(config: Configuration) {
        self.config = config
    }
    
    func updateState() {
        count += 1
    }
    
    func reset() {
        count = 0
    }
    
    func shouldFlush() -> Bool {
        count >= config.flushQueueSize
    }
}
