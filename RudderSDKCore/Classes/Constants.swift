//
//  Constants.swift
//  RudderPlugin_iOS
//
//  Created by Arnab Pal on 14/09/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

/*
 * Default value holder class
 * */
class Constants {
    // default base url or rudder-backend-server
    static let BASE_URL: String = "https://api.rudderlabs.com"
    // default flush queue size for the events to be flushed to server
    static let FLUSH_QUEUE_SIZE: Int32 = 30
    // default threshold of number of events to be persisted in sqlite db
    static let DB_COUNT_THRESHOLD: Int32 = 10000
    // default timeout for event flush
    // if events are registered and flushQueueSize is not reached
    // events will be flushed to server after sleepTimeOut seconds
    static let SLEEP_TIME_OUT: Int32 = 10
}
