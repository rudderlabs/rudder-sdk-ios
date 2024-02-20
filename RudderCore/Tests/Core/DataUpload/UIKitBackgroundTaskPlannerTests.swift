//
//  UIKitBackgroundTaskPlannerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 14/02/24.
//

import XCTest
@testable import Rudder

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

final class UIKitBackgroundTaskPlannerTests: XCTestCase {
    var testApplication: TestApplication!
    var planner: UIKitBackgroundTaskPlanner!
    
    override func setUp() {
        super.setUp()
        testApplication = TestApplication()
        planner = UIKitBackgroundTaskPlanner(application: testApplication)
    }
    
    func test_beginBackgroundTask() {
        planner?.beginBackgroundTask()
        
        XCTAssertEqual(testApplication?.beginBackgroundTask, true)
        XCTAssertEqual(testApplication?.endBackgroundTask, false)
    }
    
    func test_endBackgroundTask() {
        planner?.beginBackgroundTask()
        planner?.endBackgroundTask()
        
        XCTAssertEqual(testApplication?.beginBackgroundTask, true)
        XCTAssertEqual(testApplication?.endBackgroundTask, true)
    }
    
    func test_endBackgroundTaskNotCalledWhenNotBegan() {
        planner?.endBackgroundTask()
        
        XCTAssertEqual(testApplication?.beginBackgroundTask, false)
        XCTAssertEqual(testApplication?.endBackgroundTask, false)
    }
    
    func test_beginEndsPreviousTask() {
        planner?.beginBackgroundTask()
        planner?.beginBackgroundTask()
        
        XCTAssertEqual(testApplication?.beginBackgroundTask, true)
        XCTAssertEqual(testApplication?.endBackgroundTask, true)
    }
}

class TestApplication: UIKitAppBackgroundTaskPlanner {
    var beginBackgroundTask = false
    var endBackgroundTask = false
    
    var handler: (() -> Void)?
    
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        self.beginBackgroundTask = true
        self.handler = handler
        return UIBackgroundTaskIdentifier(rawValue: 1)
    }
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        self.endBackgroundTask = true
    }
}

#endif
