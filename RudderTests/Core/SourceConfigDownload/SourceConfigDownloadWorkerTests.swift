//
//  SourceConfigDownloadWorkerTests.swift
//  Rudder
//
//  Created by Pallab Maiti on 27/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import XCTest
@testable import Rudder

final class SourceConfigDownloadWorkerTests: XCTestCase {
    
    let queue = DispatchQueue(
        label: "sourceConfigDownloadWorkerTests".queueLabel(),
        target: .global(qos: .utility)
    )
    let logger = Logger(logger: NOLogger())
    
    func test_download() {
        let expectation = expectation(description: "SourceConfig downloaded")
        expectation.expectedFulfillmentCount = 1
        
        let retryStrategy = DownloadUploadRetryStrategy(
            retryPolicy: RetryPolicyMock(
                retryFactors: RetryFactors(
                    retryPreset: DownloadUploadRetryPreset(
                        retries: 2,
                        maxTimeout: TimeInterval(10),
                        minTimeout: TimeInterval(1),
                        factor: 2
                    ),
                    current: TimeInterval(0)
                ),
                retry: false
            )
        )
        
        let sourceConfig: SourceConfig = .mockAny()
        
        let sourceConfigDownloader = SourceConfigDownloaderMock(
            downloadStatus: APIStatus(httpResponse: .mockResponseWith(statusCode: 200)),
            onDownload: expectation.fulfill,
            sourceConfig: sourceConfig
        )
        
        let worker = SourceConfigDownloadWorker(
            sourceConfigDownloader: sourceConfigDownloader,
            downloadBlockers: NoBlockersMock(),
            userDefaults: UserDefaultsWorkerMock(queue: DispatchQueue(label: "sourceConfigDownloadWorkerTests.userDefaultsWorkerMock".queueLabel())),
            queue: queue,
            logger: logger,
            retryStrategy: retryStrategy
        )
        
        worker.sourceConfig = { expectedSourceConfig in
            XCTAssertEqual(expectedSourceConfig, sourceConfig)
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_retry() {
        let expectation = expectation(description: "Retried 4 times")
        expectation.expectedFulfillmentCount = 4
        
        let retryStrategy = DownloadUploadRetryStrategy(
            retryPolicy: RetryPolicyMock(
                retryFactors: RetryFactors(
                    retryPreset: DownloadUploadRetryPreset(
                        retries: 3,
                        maxTimeout: TimeInterval(10),
                        minTimeout: TimeInterval(1),
                        factor: 2
                    ),
                    current: TimeInterval(0)
                ),
                retry: true
            )
        )
        
        let sourceConfig: SourceConfig = .mockAny()
        
        let sourceConfigDownloader = SourceConfigDownloaderMock(
            downloadStatus: .mockWith(needsRetry: true),
            onDownload: expectation.fulfill,
            sourceConfig: sourceConfig
        )
        
        let worker = SourceConfigDownloadWorker(
            sourceConfigDownloader: sourceConfigDownloader,
            downloadBlockers: NoBlockersMock(),
            userDefaults: UserDefaultsWorkerMock(queue: DispatchQueue(label: "sourceConfigDownloadWorkerTests.userDefaultsWorkerMock".queueLabel())),
            queue: queue,
            logger: logger,
            retryStrategy: retryStrategy
        )
        
        worker.sourceConfig = { _ in }
        
        wait(for: [expectation], timeout: 6.0)
    }
}
