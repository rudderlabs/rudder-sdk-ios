//
//  DataResidencyTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 09/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class DataResidencyTests: XCTestCase {

    var urlSession: URLSession!
    var payload: String!
    var writeKey: String!
    var configDataPlaneUrl: String!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [DataResidencyURLProtocol.self]
        urlSession = URLSession.init(configuration: configuration)
        payload =
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
            }]
        }
        """
        writeKey = "write_key"
        configDataPlaneUrl = "https://dataplane.rudderstack.com"
    }
    
    func testWithBothResidenciesInSourceConfig_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "multi-dataresidency-default-true", with: config, and: .US)
    }
    
    func testWithBothResidenciesInSourceConfig_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "multi-dataresidency-default-true", with: config, and: .EU)
    }
     
    func testWithBothResidenciesInSourceConfig_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "multi-dataresidency-default-true", with: config, and: .US)
    }
    
    func testWithOnlyUSInSourceConfig_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "us-dataresidency-default-true", with: config, and: .US)
    }
    
    func testWithOnlyUSInSourceConfig_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "us-dataresidency-default-true", with: config, and: .US)
    }
    
    func testWithOnlyUSInSourceConfig_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "us-dataresidency-default-true", with: config, and: .US)
    }
        
    func testWithOnlyEUInSourceConfig_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "eu-dataresidency-default-true", with: config, and: .config)
    }
    
    func testWithOnlyEUInSourceConfig_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "eu-dataresidency-default-true", with: config, and: .EU)
    }
    
    func testWithOnlyEUInSourceConfig_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "eu-dataresidency-default-true", with: config, and: .config)
    }
        
    func testWhenNoUrlInSourceConfig_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "no-dataresidency", with: config, and: .config)
    }
    
    func testWhenNoUrlInSourceConfig_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "no-dataresidency", with: config, and: .config)
    }
    
    func testWhenNoUrlInSourceConfig_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "no-dataresidency", with: config, and: .config)
    }
        
    func testWhenNoUrlInSourceConfig_4() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: "https::/dataplanerudderstackcom")
        
        executeTest(for: "no-dataresidency", with: config, and: .config, failExpectation: true)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "multi-dataresidency-default-false", with: config, and: .config)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "multi-dataresidency-default-false", with: config, and: .config)
    }
    
    func testWithBothResidenciesInSourceConfig_DefaultFalse_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "multi-dataresidency-default-false", with: config, and: .config)
    }
        
    func testWithOnlyUSInSourceConfig_DefaultFalse_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "us-dataresidency-default-false", with: config, and: .config)
    }
    
    func testWithOnlyUSInSourceConfig_DefaultFalse_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "us-dataresidency-default-false", with: config, and: .config)
    }
    
    func testWithOnlyUSInSourceConfig_DefaultFalse_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "us-dataresidency-default-false", with: config, and: .config)
    }
        
    func testWithOnlyEUInSourceConfig_DefaultFalse_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "eu-dataresidency-default-false", with: config, and: .config)
    }
    
    func testWithOnlyEUInSourceConfig_DefaultFalse_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "eu-dataresidency-default-false", with: config, and: .config)
    }
    
    func testWithOnlyEUInSourceConfig_DefaultFalse_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "eu-dataresidency-default-false", with: config, and: .config)
    }
        
    func testWithBothResidenciesInSourceConfig_USTrue_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "multi-dataresidency-us-true", with: config, and: .US)
    }
    
    func testWithBothResidenciesInSourceConfig_USTrue_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "multi-dataresidency-us-true", with: config, and: .config)
    }
    
    func testWithBothResidenciesInSourceConfig_USTrue_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "multi-dataresidency-us-true", with: config, and: .US)
    }
        
    func testWithBothResidenciesInSourceConfig_EUTrue_1() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
        
        executeTest(for: "multi-dataresidency-eu-true", with: config, and: .config)
    }
    
    func testWithBothResidenciesInSourceConfig_EUTrue_2() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.EU)
        
        executeTest(for: "multi-dataresidency-eu-true", with: config, and: .EU)
    }
    
    func testWithBothResidenciesInSourceConfig_EUTrue_3() {
        let config = RSConfig(writeKey: writeKey, dataPlaneURL: configDataPlaneUrl)
            .dataResidencyServer(.US)
        
        executeTest(for: "multi-dataresidency-eu-true", with: config, and: .config)
    }
        
    func executeTest(for resource: String, with config: RSConfig, and expectedDataPlaneURL: ExpectedDataPlaneURL, failExpectation: Bool = false) {
        let path = TestUtils.shared.getPath(forResource: resource, ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let serverConfig = try! JSONDecoder().decode(RSServerConfig.self, from: data)
        
        let dataPlaneUrls = RSUtils.getDataPlaneUrls(from: serverConfig, and: config)
                
        let sessionStorage = RSSessionStorage()
        sessionStorage.write(.dataPlaneUrl, value: dataPlaneUrls?.first)
        
        DataResidencyURLProtocol.expectedDataPlaneURL = expectedDataPlaneURL
        
        let serviceManager = RSServiceManager(urlSession: urlSession, userDefaults: RSUserDefaults(), config: config, sessionStorage: sessionStorage)
        
        let expectation = XCTestExpectation(description: "Expectation")
        
        serviceManager.flushEvents(params: payload) { result in
            switch result {
                case .success(let status):
                    XCTAssertEqual(status, true)
                case .failure(let error):
                    if failExpectation {
                        XCTExpectFailure()
                        XCTAssertTrue(false)
                    } else {
                        XCTFail("Error was not expected: \(error)")
                    }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

class DataResidencyURLProtocol: URLProtocol {
    
    // A dictionary of mock data, where keys are URL path eg. "/weather?country=SG"
    static var expectedDataPlaneURL: ExpectedDataPlaneURL = .config
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            let data = """
            {
                
            }
            """.data(using: .utf8)
            var statusCode = 500
            switch DataResidencyURLProtocol.expectedDataPlaneURL {
            case .EU:
                if url.absoluteString == ExpectedDataPlaneURL.EU.rawValue {
                    statusCode = 201
                }
            case .US:
                if url.absoluteString == ExpectedDataPlaneURL.US.rawValue {
                    statusCode = 201
                }
            case .config:
                if url.absoluteString == ExpectedDataPlaneURL.config.rawValue {
                    statusCode = 201
                }
            }
            client?.urlProtocol(self, didLoad: data!)
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
}

enum ExpectedDataPlaneURL: String {
    case EU = "https://rudderstacgwyx-eu.dataplane.rudderstack.com/v1/batch"
    case US = "https://rudderstacgwyx-us.dataplane.rudderstack.com/v1/batch"
    case config = "https://dataplane.rudderstack.com/v1/batch"
}
