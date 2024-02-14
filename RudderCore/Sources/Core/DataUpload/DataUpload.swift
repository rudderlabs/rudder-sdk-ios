//
//  DataUpload.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class DataUpload {
    let uploader: DataUploadWorkerType
    
    init(uploader: DataUploadWorkerType) {
        self.uploader = uploader
    }
        
    func flush() {
        uploader.flushSynchronously()
    }
    
    func cancel() {
        uploader.cancel()
    }
}
