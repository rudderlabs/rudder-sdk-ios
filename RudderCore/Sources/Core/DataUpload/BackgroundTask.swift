//
//  BackgroundTask.swift
//  Rudder
//
//  Created by Pallab Maiti on 14/02/24.
//

import Foundation
import RudderInternal

/// The `BackgroundTaskPlanner` protocol provides an abstraction for managing background tasks and includes methods for starting and ending background tasks.
protocol BackgroundTaskPlanner {
    /// Starts a background task, requesting OS to allocate additional background execution time for the app.
    /// Calling it multiple times will end the previous background task and start a new one.
    func beginBackgroundTask()
    /// Ends a background task.
    func endBackgroundTask()
}

#if os(tvOS) || os(iOS) || targetEnvironment(macCatalyst)

import UIKit

/// Bridge protocol that matches `UIApplication` interface for background tasks.
/// For better testability.
protocol UIKitAppBackgroundTaskPlanner {
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: UIKitAppBackgroundTaskPlanner {}

class UIKitBackgroundTaskPlanner: BackgroundTaskPlanner {
    private let application: UIKitAppBackgroundTaskPlanner?
    
    @ReadWriteLock
    private var currentTaskId: UIBackgroundTaskIdentifier?
    
    init(
        application: UIKitAppBackgroundTaskPlanner? = UIApplication.managedShared
    ) {
        self.application = application
    }
    
    func beginBackgroundTask() {
        endBackgroundTask()
        currentTaskId = application?.beginBackgroundTask { [weak self] in
            guard let self = self else {
                return
            }
            self.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        guard let currentTaskId = currentTaskId else {
            return
        }
        if currentTaskId != .invalid {
            application?.endBackgroundTask(currentTaskId)
        }
        self.currentTaskId = nil
    }
}

extension UIApplication {
    public static var managedShared: UIApplication? {
        return UIApplication
            .value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication
    }
}
#endif

#if os(watchOS)

/// Bridge protocol that matches `DispatchSemaphore` interface.
/// For better testability.
protocol WatchKitSemaphore {
    @discardableResult func signal() -> Int
    func wait(timeout: DispatchTime) -> DispatchTimeoutResult
}

/// Bridge protocol that matches `ProcessInfo` interface for background tasks.
/// For better testability.
protocol WatchKitAppBackgroundTaskPlanner {
    func performExpiringActivity(withReason reason: String, using block: @escaping @Sendable (Bool) -> Void)
}

extension ProcessInfo: WatchKitAppBackgroundTaskPlanner { }

extension DispatchSemaphore: WatchKitSemaphore { }

class WatchKitBackgroundTaskPlanner: BackgroundTaskPlanner {
    private let application: WatchKitAppBackgroundTaskPlanner
    private let semaphore: WatchKitSemaphore
    var isSemaphoreReleased = true
    
    init(
        application: WatchKitAppBackgroundTaskPlanner = ProcessInfo.processInfo,
        semaphore: WatchKitSemaphore = DispatchSemaphore(value: 0)
    ) {
        self.application = application
        self.semaphore = semaphore
    }
    
    func beginBackgroundTask() {
        endBackgroundTask()
        application.performExpiringActivity(withReason: "BackgroundTask") { [weak self] status in
            guard let self = self else { return }
            if status {
                self.endBackgroundTask()
            }
            self.isSemaphoreReleased = status
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    func endBackgroundTask() {
        if !isSemaphoreReleased {
            semaphore.signal()
        }
    }
}

#endif
