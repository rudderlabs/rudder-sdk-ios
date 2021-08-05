//
//  RSConfig.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc open class RSConfig: NSObject {
    let dataPlaneUrl: String
    let flushQueueSize: Int
    let dbCountThreshold: Int
    let sleepTimeout: Int
    let logLevel: Int
    let configRefreshInterval: Int
    let trackLifecycleEvents: Bool
    let recordScreenViews: Bool
    let controlPlaneUrl: String
    let factories: [RSIntegrationFactory]
    
    public override init() {
        dataPlaneUrl = Constants.RSDataPlaneUrl
        flushQueueSize = Constants.RSFlushQueueSize
        dbCountThreshold = Constants.RSDBCountThreshold
        sleepTimeout = Constants.RSSleepTimeout
        logLevel = 1 //TODO: Need to replace with RSLogger
        configRefreshInterval = Constants.RSConfigRefreshInterval
        trackLifecycleEvents = Constants.RSTrackLifeCycleEvents
        recordScreenViews = Constants.RSRecordScreenViews
        controlPlaneUrl = Constants.RSControlPlaneUrl
        factories = [RSIntegrationFactory]()
    }
    
    init(dataPlaneUrl: String, flushQueueSize: Int, dbCountThreshold: Int, sleepTimeout: Int, logLevel: Int, configRefreshInterval: Int, trackLifecycleEvents: Bool, recordScreenViews: Bool, controlPlaneUrl: String) {
        self.dataPlaneUrl = dataPlaneUrl
        self.flushQueueSize = flushQueueSize
        self.dbCountThreshold = dbCountThreshold
        self.sleepTimeout = sleepTimeout
        self.logLevel = logLevel
        self.configRefreshInterval = configRefreshInterval
        self.trackLifecycleEvents = trackLifecycleEvents
        self.recordScreenViews = recordScreenViews
        self.controlPlaneUrl = controlPlaneUrl
        self.factories = [RSIntegrationFactory]()
    }
}
