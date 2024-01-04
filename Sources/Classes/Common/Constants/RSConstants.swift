//
//  RSConstants.swift
//  RudderStack
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

let TAG = "RudderStack"
let RUDDER_DESTINATION_KEY = "RudderStack"
let RSServerConfigKey = "rs_server_config"
let RSServerLastUpdatedKey = "rs_server_last_updated"
let RSTraitsKey = "rs_traits"
let RSUserIdKey = "rs_user_id"
let RSApplicationVersionKey = "rs_application_version_key"
let RSApplicationBuildKey = "rs_application_build_key"
let RSExternalIdKey = "rs_external_id"
let RSAnonymousIdKey = "rs_anonymous_id"
let RSOptStatusKey = "rs_opt_status"
let RSOptInTimeKey = "rs_opt_in_time"
let RSOptOutTimeKey = "rs_opt_out_time"
let RSSessionIdKey = "rl_session_id"
let RSLastEventTimeStamp = "rl_last_event_time_stamp"
let RSSessionAutoTrackStatus = "rl_session_auto_track_status"
let RSSessionManualTrackStatus = "rl_session_manual_track_status"
let RSSessionStoppedStatus = "rl_session_stopped_status"

let DEFAULT_DATA_PLANE_URL = "https://hosted.rudderlabs.com"
let DEFAULT_CONTROL_PLANE_URL = "https://api.rudderlabs.com"
let DEFAULT_TRACK_LIFE_CYCLE_EVENTS_STATUS = true
let DEFAULT_RECORD_SCREEN_VIEWS_STATUS = false
let DEFAULT_AUTO_SESSION_TRACKING_STATUS = true
let DEFAULT_GZIP_ENABLED_STATUS = true

let DEFAULT_FLUSH_QUEUE_SIZE = 30
let MAX_FLUSH_QUEUE_SIZE = 100
let MIN_FLUSH_QUEUE_SIZE = 1

let DEFAULT_DB_COUNT_THRESHOLD = 10000
let MIN_DB_COUNT_THRESHOLD = 1

let DEFAULT_SLEEP_TIMEOUT = 10
let MIN_SLEEP_TIMEOUT = 10

let DEFAULT_SESSION_TIMEOUT: Int = 300000
let MIN_SESSION_TIMEOUT = 0

let MAX_EVENT_SIZE: UInt = 32 * 1024
let MAX_BATCH_SIZE: UInt = 500 * 1024
let RETRY_FLUSH_COUNT = 3
