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
let RETRY_FLUSH_COUNT = 3
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
let RSAutoSessionTracking: Bool = true
let RSSessionTimeout: Int = 300000
let RSSessionInActivityMinimumTimeOut = 0
let RSSessionIdKey = "rl_session_id"
let RSLastEventTimeStamp = "rl_last_event_time_stamp"
let RSSessionAutoTrackStatus = "rl_session_auto_track_status"
let RSSessionManualTrackStatus = "rl_session_manual_track_status"
let RSSessionStoppedStatus = "rl_session_stopped_status"
