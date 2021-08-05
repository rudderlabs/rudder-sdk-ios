//
//  Constants.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class Constants {
    static let RSConfigRefreshInterval: Int = 2
    static let RSDataPlaneUrl: String = "https://hosted.rudderlabs.com"
    static let RSFlushQueueSize: Int = 30
    static let RSDBCountThreshold: Int = 10000
    static let RSSleepTimeout: Int = 10
    static let RSControlPlaneUrl: String = "https://api.rudderlabs.com"
    static let RSTrackLifeCycleEvents: Bool = true
    static let RSRecordScreenViews: Bool = false
    static let RS_VERSION: String = "1.0.21"
}
