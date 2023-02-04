//
//  ConserFilterHandlerTests.swift
//  RudderTests
//
//  Created by Pallab Maiti on 27/01/23.
//

import XCTest
@testable import Rudder

final class ConserFilterHandlerTests: XCTestCase {

    var consentFilter: RSConsentFilter!
    var consentFilterHandler: RSConsentFilterHandler!
    
    override func setUp() {
        super.setUp()
        consentFilter = TestConsentFilter()
        let serverConfig = RSServerConfigSource()
        consentFilterHandler = RSConsentFilterHandler.initiate(consentFilter, withServerConfig: serverConfig)
    }

    override func tearDown() {
        super.tearDown()
        consentFilter = nil
        consentFilterHandler = nil
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
        
        for _ in 0..<100 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                consentFilterHandler.isFactoryConsented("key")
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
    func filterConsentedDestinations(_ destinations: [RSServerDestination]) -> [String : NSNumber]? {
        return [:]
    }
}
