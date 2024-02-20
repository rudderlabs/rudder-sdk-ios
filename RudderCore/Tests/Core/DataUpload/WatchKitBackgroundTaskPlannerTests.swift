//
//  WatchKitBackgroundTaskPlannerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 21/02/24.
//

import XCTest
@testable import Rudder

#if os(watchOS)

final class WatchKitBackgroundTaskPlannerTests: XCTestCase {
    var testSemaphore: TestSemaphore!
    var testApplication: TestApplication!
    var planner: WatchKitBackgroundTaskPlanner!
    
    override func setUp() {
        super.setUp()
        testApplication = TestApplication()
        testSemaphore = TestSemaphore()
        planner = WatchKitBackgroundTaskPlanner(application: testApplication, semaphore: testSemaphore)
    }
    
    func test_beginBackgroundTask() {
        planner?.beginBackgroundTask()
        testApplication.block?(false)
        
        XCTAssertEqual(testSemaphore?.beginBackgroundTask, true)
        XCTAssertEqual(testSemaphore?.endBackgroundTask, false)
        
        testApplication.block?(true)
        XCTAssertEqual(testSemaphore?.endBackgroundTask, true)
    }
    
    func test_endBackgroundTask() {
        planner?.beginBackgroundTask()
        testApplication.block?(false)
        
        planner?.endBackgroundTask()
        
        XCTAssertEqual(testSemaphore?.beginBackgroundTask, true)
        XCTAssertEqual(testSemaphore?.endBackgroundTask, true)
    }
    
    func test_endBackgroundTaskNotCalledWhenNotBegan() {
        planner?.endBackgroundTask()
        
        XCTAssertEqual(testSemaphore?.beginBackgroundTask, false)
        XCTAssertEqual(testSemaphore?.endBackgroundTask, false)
    }
    
    func test_beginEndsPreviousTask() {
        planner?.beginBackgroundTask()
        testApplication.block?(false)
        
        planner?.beginBackgroundTask()
        testApplication.block?(false)
        
        XCTAssertEqual(testSemaphore?.beginBackgroundTask, true)
        XCTAssertEqual(testSemaphore?.endBackgroundTask, true)
    }
}

class TestApplication: WatchKitAppBackgroundTaskPlanner {
    var block: ((Bool) -> Void)?
    
    func performExpiringActivity(withReason reason: String, using block: @escaping (Bool) -> Void) {
        self.block = block
    }
}

class TestSemaphore: WatchKitSemaphore {
    var beginBackgroundTask = false
    var endBackgroundTask = false

    func signal() -> Int {
        endBackgroundTask = true
        return 1
    }
    
    func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
        beginBackgroundTask = true
        return .success
    }
}

#endif
