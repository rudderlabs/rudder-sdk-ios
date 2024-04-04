//
//  Constants.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public class Constants {
    static let queueSize = QueueSize()
    static let storageCountThreshold = StorageCountThreshold()
    static let sleepTimeOut = SleepTimeOut()
    static let sessionTimeOut = SessionTimeOut()
    static let messageSize = MessageSize()
    static let batchSize = BatchSize()
    static let controlPlaneUrl = ControlPlaneUrl()
    static let trackLifeCycleEvent = TrackLifeCycleEvent()
    static let recordScreenViews = RecordScreenViews()
    static let autoSessionTracking = AutoSessionTracking()
    static let gzipEnabled = GzipEnabled()
    static let residencyServer = ResidencyServer()
}

protocol DefaultValue {
    associatedtype RawValue: Any
    var `default`: RawValue { get }
}

protocol MaxValue {
    var max: Int { get }
}

protocol MinValue {
    var min: Int { get }
}

struct QueueSize: DefaultValue, MaxValue, MinValue {
    var `default`: Int = 30
    var max: Int = 100
    var min: Int = 1
}

struct StorageCountThreshold: DefaultValue, MinValue {
    var `default`: Int = 10000
    var min: Int = 1
}

struct SleepTimeOut: DefaultValue, MinValue {
    var `default`: Int = 10
    var min: Int = 10
}

struct SessionTimeOut: DefaultValue, MinValue {
    var `default`: Int = 300000
    var min: Int = 0
}

struct MessageSize: DefaultValue {
    var `default`: Int = 32 * 1024
}

struct BatchSize: DefaultValue {
    var `default`: Int = 500 * 1024
}

struct ControlPlaneUrl: DefaultValue {
    var `default`: String = "https://api.rudderlabs.com"
}

struct TrackLifeCycleEvent: DefaultValue {
    var `default`: Bool = true
}

struct RecordScreenViews: DefaultValue {
    var `default`: Bool = false
}

struct AutoSessionTracking: DefaultValue {
    var `default`: Bool = true
}

struct GzipEnabled: DefaultValue {
    var `default`: Bool = true
}

struct ResidencyServer: DefaultValue {
    var `default`: DataResidencyServer = .US
}
