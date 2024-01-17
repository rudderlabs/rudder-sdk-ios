//
//  DataUploader.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol DataUploaderType {
    func upload(messages: [StorageMessage]) -> APIStatus
    func updateDataPlaneUrl(_ dataPlaneUrl: String)
}

public extension DataUploaderType {
    func updateDataPlaneUrl(_ dataPlaneUrl: String) { }
}

class DataUploader: DataUploaderType {
    let serviceManager: ServiceType
    let anonymousId: String
    let gzipEnabled: Bool
    @ReadWriteLock var dataPlaneUrl: String
    
    init(serviceManager: ServiceType, anonymousId: String, gzipEnabled: Bool, dataPlaneUrl: String) {
        self.serviceManager = serviceManager
        self.anonymousId = anonymousId
        self.gzipEnabled = gzipEnabled
        self.dataPlaneUrl = dataPlaneUrl
    }
    
    func upload(messages: [StorageMessage]) -> APIStatus {
        let params = messages.toJSONString()
        var uploadStatus: APIStatus?
        let semaphore = DispatchSemaphore(value: 0)
        serviceManager.flushBatch(params: params, anonymousId: anonymousId, gzipEnabled: gzipEnabled, dataPlaneUrl: dataPlaneUrl) { result in
            switch result {
            case .success(let response):
                uploadStatus = APIStatus(responseStatusCode: response.statusCode)
            case .failure(let error):
                uploadStatus = APIStatus(error: error)
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return uploadStatus ?? APIStatus(needsRetry: false, responseCode: nil, error: nil)
    }
    
    func updateDataPlaneUrl(_ dataPlaneUrl: String) {
        self.dataPlaneUrl = dataPlaneUrl
    }
}
