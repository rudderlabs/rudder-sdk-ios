//
//  SourceConfigDownloader.swift
//  Rudder
//
//  Created by Pallab Maiti on 17/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public struct SourceConfigDownloadResponse: Equatable {
    let sourceConfig: SourceConfig?
    let status: APIStatus
}

public protocol SourceConfigDownloaderType {
    func download() -> SourceConfigDownloadResponse
}

class SourceConfigDownloader: SourceConfigDownloaderType {
    let serviceManager: ServiceType
    let controlPlaneUrl: String
    
    init(serviceManager: ServiceType, controlPlaneUrl: String) {
        self.serviceManager = serviceManager
        self.controlPlaneUrl = controlPlaneUrl
    }
    
    func download() -> SourceConfigDownloadResponse {
        var downloadStatus: APIStatus?
        var sourceConfig: SourceConfig?
        let semaphore = DispatchSemaphore(value: 0)
        serviceManager.downloadSourceConfig(controlPlaneUrl: controlPlaneUrl, { result in
            switch result {
            case .success(let response):
                sourceConfig = response.value
                downloadStatus = APIStatus(responseStatusCode: response.statusCode)
            case .failure(let error):
                downloadStatus = APIStatus(error: error)
            }
            semaphore.signal()
        })
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return SourceConfigDownloadResponse(
            sourceConfig: sourceConfig,
            status: downloadStatus ?? APIStatus(
                needsRetry: false,
                responseCode: nil,
                error: nil
            )
        )
    }
}
