//
//  RSRepeatingTimer.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

internal class RSRepeatingTimer {
    enum State {
        case suspended
        case resumed
    }
    
    let interval: TimeInterval
    let timer: DispatchSourceTimer
    let queue: DispatchQueue
    let handler: () -> Void
    
    @RSAtomic var state: State = .suspended
    
    static var timers = [RSRepeatingTimer]()
    
    static func schedule(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        let timer = RSRepeatingTimer(interval: interval, queue: queue, handler: handler)
        Self.timers.append(timer)
    }

    init(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        self.interval = interval
        self.queue = queue
        self.handler = handler
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.schedule(deadline: .now() + self.interval, repeating: self.interval)
        timer.setEventHandler { [weak self] in
            self?.handler()
        }
        resume()
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        timer.setEventHandler {
            // do nothing ...
        }
        // if timer is suspended, we must resume if we're going to cancel.
        timer.cancel()
        resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
}

extension TimeInterval {
    static func milliseconds(_ value: Int) -> TimeInterval {
        return TimeInterval(value / 1000)
    }
    
    static func seconds(_ value: Int) -> TimeInterval {
        return TimeInterval(value)
    }
    
    static func hours(_ value: Int) -> TimeInterval {
        return TimeInterval(60 * value)
    }
    
    static func days(_ value: Int) -> TimeInterval {
        return TimeInterval((60 * value) * 24)
    }
}
