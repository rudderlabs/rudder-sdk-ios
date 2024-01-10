//
//  ServiceManagerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 08/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class ServiceManagerTests: XCTestCase {

    var serviceManager: RSServiceType!
    var promise: XCTestExpectation!
    let apiURL = URL(string: "https://some.rudderstack.com.url")!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        let config = RSConfig(writeKey: "write_key", dataPlaneURL: "")
        serviceManager = RSServiceManager(urlSession: urlSession, userDefaults: RSUserDefaults(), config: config, sessionStorage: RSSessionStorage())
        promise = expectation(description: "Expectation")
    }
    
    func test_flushEvents() {
        let payload =
        """
        {
            "sentAt": "2022-01-31T11:38:08.731Z",
            "batch": [{
                "messageId": "1643629010-3615180d-edab-4f56-94a2-46ac2e68d39c",
                "anonymousId": "anonymous_id",
                "channel": "mobile",
                "event": "simple_track_with_props",
                "context": {
                    "screen": {
                        "density": 3,
                        "width": 844,
                        "height": 390
                    },
                    "os": {
                        "name": "iOS",
                        "version": "15.2"
                    },
                    "locale": "en-US",
                    "app": {
                        "version": "1.0",
                        "namespace": "com.rudderstack.ios.test.objc",
                        "name": "RudderSampleAppObjC",
                        "build": "1"
                    },
                    "device": {
                        "manufacturer": "Apple",
                        "id": "42f0686d-564d-4e2d-815c-a9380dd8b70f",
                        "model": "iPhone",
                        "type": "iOS",
                        "token": "your_device_token",
                        "attTrackingStatus": 0,
                        "name": "iPhone 12"
                    },
                    "traits": {
                        "anonymousId": "anonymous_id"
                    },
                    "library": {
                        "name": "rudder-ios-library",
                        "version": "1.5.0"
                    },
                    "timezone": "Asia/Kolkata",
                    "network": {
                        "bluetooth": false,
                        "wifi": true,
                        "carrier": "unavailable",
                        "cellular": false
                    }
                },
                "originalTimestamp": "2022-01-31T11:36:50.055Z",
                "properties": {
                    "key_1": "value_1",
                    "key_2": "value_2"
                },
                "type": "track",
                "integrations": {
                    "All": true
                },
                "sentAt": "2022-01-31T11:38:08.731Z"
            }
            ]
        }
        """
        let data = """
        {
        
        }
        """.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: self.apiURL, statusCode: 201, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        serviceManager.flushEvents(params: payload) { result in
            switch result {
                case .success(let status):
                    XCTAssertEqual(status, true)
                case .failure(let error):
                    XCTFail("Error was not expected: \(error)")
            }
            self.promise.fulfill()
        }
        wait(for: [promise], timeout: 1.0)
    }
}

class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        
    }
}
