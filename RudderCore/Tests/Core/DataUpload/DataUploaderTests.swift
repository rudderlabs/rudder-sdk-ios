//
//  DataUploaderTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 26/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class DataUploaderTests: XCTestCase {
    
    func test_CompletesWithResponse() {
        // Given
        let response: HTTPURLResponse = .mockResponseWith(statusCode: (200..<600).randomElement()!)
        
        let uploader = DataUploader(
            serviceManager: ServiceManager(
                apiClient: APIClientMock(
                    response: response
                ),
                writeKey: .mockRandom(length: 27)
            ),
            anonymousId: .mockRandom(length: 10),
            gzipEnabled: .mockAny(),
            dataPlaneUrl: .mockAnyURL()
        )
        
        // When
        let uploadStatus = uploader.upload(
            messages: [.mockAny()]
        )
        
        // Then
        let expectedUploadStatus = APIStatus(httpResponse: response)
        XCTAssertEqual(uploadStatus, expectedUploadStatus)
    }
    
    func test_CompletesWithError() {
        // Given
        let error = NSError(domain: .mockRandom(), code: .mockRandom())
        
        let uploader = DataUploader(
            serviceManager: ServiceManager(
                apiClient: APIClientMock(
                    error: error
                ),
                writeKey: .mockRandom(length: 27)
            ),
            anonymousId: .mockRandom(length: 10),
            gzipEnabled: .mockAny(),
            dataPlaneUrl: .mockAnyURL()
        )
        
        // When
        let uploadStatus = uploader.upload(
            messages: [.mockAny()]
        )
        
        // Then
        let expectedUploadStatus = APIStatus(error: error)
        XCTAssertEqual(uploadStatus, expectedUploadStatus)
    }
}
