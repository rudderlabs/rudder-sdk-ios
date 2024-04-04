//
//  SourceConfigDownload.swift
//  Rudder
//
//  Created by Pallab Maiti on 28/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class SourceConfigDownload {
    private var downloader: SourceConfigDownloadWorkerType
    var sourceConfig: ((SourceConfig) -> Void) = { _ in }
    
    init(downloader: SourceConfigDownloadWorkerType) {
        self.downloader = downloader
        self.downloader.sourceConfig = { sourceConfig in
            self.sourceConfig(sourceConfig)
        }
    }
}
