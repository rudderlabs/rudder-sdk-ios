//
//  SourceConfigDownloaderTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 28/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class SourceConfigDownloaderTests: XCTestCase {
    func test_CompletesWithResponse() {
        // Given
        let response: HTTPURLResponse = .mockResponseWith(statusCode: (200..<300).randomElement()!)
        let sourceConfig: SourceConfig = .mockAny()
        
        let downloader = SourceConfigDownloader(
            serviceManager: ServiceManager(
                apiClient: APIClientMock(
                    response: response,
                    data: try? JSONEncoder().encode(sourceConfig)
                ),
                writeKey: .mockRandom(length: 27)
            ),
            controlPlaneUrl: .mockAnyURL()
        )
        
        // When
        let downloadStatus = downloader.download()
        
        // Then
        let expectedUploadStatus = SourceConfigDownloadResponse(
            sourceConfig: sourceConfig,
            status: APIStatus(
                httpResponse: response
            )
        )
        XCTAssertEqual(downloadStatus, expectedUploadStatus)
    }
    
    func test_CompletesWithError() {
        // Given
        let error = NSError(domain: .mockRandom(), code: .mockRandom())
        
        let downloader = SourceConfigDownloader(
            serviceManager: ServiceManager(
                apiClient: APIClientMock(
                    error: error
                ),
                writeKey: .mockRandom(length: 27)
            ),
            controlPlaneUrl: .mockAnyURL()
        )
        
        // When
        let downloadStatus = downloader.download()
        
        // Then
        let expectedUploadStatus = SourceConfigDownloadResponse(
            sourceConfig: nil,
            status: APIStatus(
                error: error
            )
        )
        XCTAssertEqual(downloadStatus, expectedUploadStatus)
    }
}
