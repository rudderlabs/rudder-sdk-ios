//
//  ConserFilterHandlerTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class ConserFilterHandlerTests: XCTestCase {
    
    func test_checkConsentedIntegration() {
        let consentFilterHandler2 = RSConsentFilterHandler.initiate(TestConsentFilter(), withServerConfig: RSServerConfigSource())
        
        XCTAssertEqual(consentFilterHandler2.isFactoryConsented("key_1"), true)
        XCTAssertEqual(consentFilterHandler2.isFactoryConsented("key_2"), false)
        XCTAssertEqual(consentFilterHandler2.isFactoryConsented("key_10"), true)
    }
    
    func test_updateConsentedIntegrationsDictThreadSafety() {
        let internalServerConfig = RSServerConfigSource()
        let consentFilterHandler = RSConsentFilterHandler.initiate(TestConsentFilter(), withServerConfig: internalServerConfig)
        
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "multi thread")
        for _ in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                consentFilterHandler.updateConsentedIntegrationsDict()
                dispatchGroup.leave()
            }
        }
        
        for _ in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                consentFilterHandler.updateConsentedIntegrationsDict()
                dispatchGroup.leave()
            }
        }
        
        for i in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                consentFilterHandler.isFactoryConsented("key_\(i)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
}

class TestConsentFilter: RSConsentFilter {
    var count = 0
    func filterConsentedDestinations(_ destinations: [RSServerDestination]) -> [String: NSNumber]? {
        count += 1
        return ["key_\(count)": NSNumber(booleanLiteral: true), "key_\(count + 1)": NSNumber(booleanLiteral: false)]
    }
}
