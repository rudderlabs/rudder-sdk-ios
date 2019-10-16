//
//  RudderContext.swift
//  RudderSample
//
//  Created by Arnab Pal on 12/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

public class RudderContext: NSObject, Encodable {
    var app: RudderApp = RudderApp()
    var traits: RudderTraits? = nil
    var library: RudderLibraryInfo = RudderLibraryInfo()
    var os: RudderOSInfo = RudderOSInfo()
    var screenInfo: RudderScreenInfo = RudderScreenInfo()
    var userAgent: String = "rudder-ios-client"
    var locale: String = (Locale.current.languageCode ?? "") + "-" + (Locale.current.regionCode ?? "")
    var deviceInfo: RudderDeviceInfo = RudderDeviceInfo()
    var network: RudderNetwork = RudderNetwork()
    var timeZone: String = TimeZone.current.identifier
    
    override init() {
        self.traits = RudderTraits(anonymousId: self.deviceInfo.id)
    }
    
    enum CodingKeys: String, CodingKey {
        case app = "app"
        case traits = "traits"
        case library = "library"
        case os = "os"
        case screenInfo = "screen"
        case userAgent = "userAgent"
        case locale = "locale"
        case deviceInfo = "device"
        case network = "network"
        case timeZone = "timezone"
    }
}
