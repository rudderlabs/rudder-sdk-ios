//
//  RSConstants.swift
//  RudderStack
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public let RSDataPlaneUrl = "https://hosted.rudderlabs.com"
public let RSFlushQueueSize: Int = 30
public let RSDBCountThreshold: Int = 10000
public let RSSleepTimeout: Int = 10
public let RSControlPlaneUrl = "https://api.rudderlabs.com"
public let RSTrackLifeCycleEvents = true
public let RSRecordScreenViews = false
let TAG = "RudderStack"
let RSServerConfigKey = "rs_server_config"
let RSServerLastUpdatedKey = "rs_server_last_updated"
let RSTraitsKey = "rs_traits"
let RSApplicationVersionKey = "rs_application_version_key"
let RSApplicationBuildKey = "rs_application_build_key"
let RSExternalIdKey = "rs_external_id"
let RSAnonymousIdKey = "rs_anonymous_id"
let RSOptStatusKey = "rs_opt_status"
let RSOptInTimeKey = "rs_opt_in_time"
let RSOptOutTimeKey = "rs_opt_out_time"
let MAX_EVENT_SIZE: UInt = 32 * 1024
let MAX_BATCH_SIZE: UInt = 500 * 1024

// don't move this line
let RSVersion = "2.0.0"
