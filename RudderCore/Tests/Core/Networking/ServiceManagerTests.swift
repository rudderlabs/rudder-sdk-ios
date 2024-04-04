//
//  ServiceManagerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 28/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class ServiceManagerTests: XCTestCase {
    
    func test_downloadSourceConfig_Success() {
        let response: HTTPURLResponse = .mockResponseWith(statusCode: 200)
        let sourceConfig: SourceConfig = .mockAny()
        let apiClient = APIClientMock(response: response, data: try? JSONEncoder().encode(sourceConfig))
        let serviceManager = ServiceManager(apiClient: apiClient, writeKey: "write_key")
        
        let expectation = expectation(description: "Source config can be downloaded")
        serviceManager.downloadSourceConfig(controlPlaneUrl: .mockAny()) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.value, sourceConfig)
                expectation.fulfill()
            case .failure:
                XCTFail("Server shouldn't return error")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_downloadSourceConfig_Failure() {
        let response: HTTPURLResponse = .mockResponseWith(statusCode: 500)
        let apiClient = APIClientMock(response: response)
        let serviceManager = ServiceManager(apiClient: apiClient, writeKey: "write_key")
        
        let expectation = expectation(description: "Source config can not be downloaded")
        serviceManager.downloadSourceConfig(controlPlaneUrl: .mockAny()) { result in
            switch result {
            case .success:
                XCTFail("Server shouldn't return response")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_flushBatch_Success() {
        let response: HTTPURLResponse = .mockResponseWith(statusCode: 200)
        let apiClient = APIClientMock(response: response)
        let serviceManager = ServiceManager(apiClient: apiClient, writeKey: "write_key")
        
        let expectation = expectation(description: "Events should be flushed")
        serviceManager.flushBatch(
            params: """
                    {
                        "key_1": "value_1"
                    }
                    """,
            anonymousId: "anonymousId",
            gzipEnabled: true,
            dataPlaneUrl: .mockAnyURL()
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.value)
                expectation.fulfill()
            case .failure:
                XCTFail("Server shouldn't return error")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_flushBatch_Failure() {
        let response: HTTPURLResponse = .mockResponseWith(statusCode: 500)
        let apiClient = APIClientMock(response: response, data: nil)
        let serviceManager = ServiceManager(apiClient: apiClient, writeKey: "write_key")
        
        let expectation = expectation(description: "Events should not be flushed")
        serviceManager.flushBatch(
            params: """
                    {
                        "key_1": "value_1"
                    }
                    """,
            anonymousId: "anonymousId",
            gzipEnabled: true,
            dataPlaneUrl: .mockAnyURL()
        ) { result in
            switch result {
            case .success:
                XCTFail("Server shouldn't return response")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
