//
//  UserSessionTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/09/23.
//

import XCTest
@testable import Rudder

final class UserSessionTests: XCTestCase {
    
    var userSession: RSUserSession!
    
    override func setUp() {
        super.setUp()
        let preferenceManager = RSPreferenceManager.getInstance()
        userSession = RSUserSession.initiate(10, with: preferenceManager)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_startSession() {
        userSession.start()
        
        XCTAssertEqual(userSession.getId(), RSPreferenceManager.getInstance().getSessionId())
        userSession.clear()
    }
    
    func test_startSessionWithId() {
        userSession.start(12345678)
        
        XCTAssertEqual(userSession.getId(), 12345678)
        XCTAssertEqual(RSPreferenceManager.getInstance().getSessionId(), 12345678)
        userSession.clear()
    }
    
    func test_clearSession() {
        userSession.start()
        
        XCTAssertEqual(userSession.getId(), RSPreferenceManager.getInstance().getSessionId())
        userSession.clear()
        
        XCTAssertNil(userSession.getId())
        XCTAssertNil(RSPreferenceManager.getInstance().getSessionId())
    }
}
