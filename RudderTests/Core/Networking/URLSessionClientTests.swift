//
//  URLSessionClientTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 08/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class URLSessionClientTests: XCTestCase {
    
    func test_ReturnResponse() {
        let server = ServerMock(serverResult: .success(response: .mockResponseWith(statusCode: 200)))
        let client = URLSessionClient(session: server.getInterceptedURLSession())
        
        let expectation = expectation(description: "Returns response")
        
        client.send(request: .mockAny()) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.urlResponse.statusCode, 200)
                expectation.fulfill()
            case .failure:
                XCTFail("Server shouldn't return error")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_ReturnsError() {
        let server = ServerMock(serverResult: .failure(error: NSError(domain: "Mock Error", code: 500)))
        let client = URLSessionClient(session: server.getInterceptedURLSession())
        
        let expectation = expectation(description: "Returns response")
        
        client.send(request: .mockAny()) { result in
            switch result {
            case .success:
                    XCTFail("Server shouldn't return response")
            case .failure(let error):
                XCTAssertEqual((error as NSError).domain, "Mock Error")
                XCTAssertEqual((error as NSError).code, 500)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

