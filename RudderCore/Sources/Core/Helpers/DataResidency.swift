//
//  DataResidency.swift
//  Rudder
//
//  Created by Pallab Maiti on 23/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

protocol DataResidencyType {
    var dataPlaneUrl: String? { get }
}

class DataResidency: DataResidencyType {
    var dataPlaneUrl: String? {
        var dataPlanes: [SourceConfig.Source.DataPlanes.DataPlane]?
        if dataResidencyServer == .EU {
            dataPlanes = sourceConfig.source?.dataPlanes?.eu
        }
        
        if dataPlanes == nil {
            dataPlanes = sourceConfig.source?.dataPlanes?.us
        }
        
        let dataPlane = dataPlanes?.filter({ $0.default })
        
        if let urls = dataPlane?.compactMap({ $0.url }), !urls.isEmpty {
            return urls.first
        }
        return nil
    }
    
    let dataResidencyServer: DataResidencyServer
    let sourceConfig: SourceConfig
    
    init(dataResidencyServer: DataResidencyServer, sourceConfig: SourceConfig) {
        self.dataResidencyServer = dataResidencyServer
        self.sourceConfig = sourceConfig
    }
}
