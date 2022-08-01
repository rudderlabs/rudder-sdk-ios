//
//  RSSessionStorage.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/07/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSSessionStorage {
    enum Keys: String {
        case deviceToken
        case advertisingId
        case appTrackingConsent
        case option
    }
    
    static let shared = RSSessionStorage()
    private let syncQueue = DispatchQueue(label: "sessionStorage.rudder.com")
    private var deviceToken: String?
    private var advertisingId: String?
    private var appTrackingConsent: RSAppTrackingConsent?
    private var option: RSOption?

    func write<T: Any>(_ key: RSSessionStorage.Keys, value: T?) {
        syncQueue.sync {
            switch key {
            case .deviceToken:
                deviceToken = value as? String
            case .advertisingId:
                advertisingId = value as? String
            case .appTrackingConsent:
                appTrackingConsent = value as? RSAppTrackingConsent
            case .option:
                option = value as? RSOption
            }
        }
    }
    
    func read<T: Any>(_ key: RSSessionStorage.Keys) -> T? {
        var result: T?
        syncQueue.sync {
            switch key {
            case .deviceToken:
                result = deviceToken as? T
            case .advertisingId:
                result = advertisingId as? T
            case .appTrackingConsent:
                result = appTrackingConsent as? T
            case .option:
                result = option as? T
            }
        }
        return result
    }
    
    func reset() {
        syncQueue.sync {
            option = nil
        }
    }
}
