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
    var sourceConfig: ((SourceConfig, NeedsDatabaseMigration) -> Void) = { _, _ in }
    
    init(downloader: SourceConfigDownloadWorkerType) {
        self.downloader = downloader
        self.downloader.sourceConfig = { sourceConfig, needsDatabaseMigration in
            self.sourceConfig(sourceConfig, needsDatabaseMigration)
        }
    }
}
