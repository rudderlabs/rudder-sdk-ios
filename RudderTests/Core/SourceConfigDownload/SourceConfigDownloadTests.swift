//
//  SourceConfigDownloadTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 28/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class SourceConfigDownloadTests: XCTestCase {
    let queue = DispatchQueue(
        label: "sourceConfigDownloadTests".queueLabel(),
        target: .global(qos: .utility)
    )
    let logger = Logger(logger: NOLogger())

    func test_SourceConfigPersisted() {
        // Given
        let expectation = expectation(description: "SourceConfig persisted")
        expectation.expectedFulfillmentCount = 2
        
        let retryStrategy = DownloadUploadRetryStrategy(
            retryPolicy: RetryPolicyMock(
                retryFactors: RetryFactors(
                    retryPreset: DownloadUploadRetryPreset.noOp,
                    current: TimeInterval(0)
                ),
                retry: false
            )
        )
        
        let cachedSourceConfig: SourceConfig = .mockAny()
        let downloadedSourceConfig: SourceConfig = .mockWith(
            source: .mockWith(
                id: cachedSourceConfig.id,
                writeKey: cachedSourceConfig.writeKey,
                enabled: false
            )
        )
        
        let sourceConfigDownloader = SourceConfigDownloaderMock(
            downloadStatus: APIStatus(httpResponse: .mockResponseWith(statusCode: 200)),
            sourceConfig: downloadedSourceConfig
        )
        
        let worker = SourceConfigDownloadWorker(
            sourceConfigDownloader: sourceConfigDownloader,
            downloadBlockers: NoBlockersMock(),
            userDefaults: UserDefaultsWorkerMock(
                value: cachedSourceConfig, 
                queue: DispatchQueue(
                    label: "sourceConfigDownloadWorkerTests.userDefaultsWorkerMock".queueLabel()
                )
            ),
            queue: queue,
            logger: logger,
            retryStrategy: retryStrategy
        )
        
        // When
        let download = SourceConfigDownload(downloader: worker)
        
        // Then
        var count = 0
        download.sourceConfig = { sourceConfig in
            expectation.fulfill()
            if count == 0 {
                XCTAssertEqual(cachedSourceConfig, sourceConfig)
            } else {
                XCTAssertEqual(downloadedSourceConfig, sourceConfig)
            }
            count += 1
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_SourceConfigNotPersisted() {
        // Given
        let expectation = expectation(description: "SourceConfig persisted")
        expectation.expectedFulfillmentCount = 1
        
        let retryStrategy = DownloadUploadRetryStrategy(
            retryPolicy: RetryPolicyMock(
                retryFactors: RetryFactors(
                    retryPreset: DownloadUploadRetryPreset.noOp,
                    current: TimeInterval(0)
                ),
                retry: false
            )
        )
        
        let downloadedSourceConfig: SourceConfig = .mockAny()
        
        let sourceConfigDownloader = SourceConfigDownloaderMock(
            downloadStatus: APIStatus(httpResponse: .mockResponseWith(statusCode: 200)),
            sourceConfig: downloadedSourceConfig
        )
        
        let worker = SourceConfigDownloadWorker(
            sourceConfigDownloader: sourceConfigDownloader,
            downloadBlockers: NoBlockersMock(),
            userDefaults: UserDefaultsWorkerMock(
                queue: DispatchQueue(
                    label: "sourceConfigDownloadWorkerTests.userDefaultsWorkerMock".queueLabel()
                )
            ),
            queue: queue,
            logger: logger,
            retryStrategy: retryStrategy
        )
        
        // When
        let download = SourceConfigDownload(downloader: worker)
        
        // Then
        download.sourceConfig = { sourceConfig in
            expectation.fulfill()
            XCTAssertEqual(downloadedSourceConfig, sourceConfig)
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
