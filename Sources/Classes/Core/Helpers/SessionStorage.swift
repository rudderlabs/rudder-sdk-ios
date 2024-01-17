//
//  SessionStorage.swift
//  Rudder
//
//  Created by Pallab Maiti on 16/07/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class SessionStorage {
    enum Keys: String {
        case deviceToken
        case advertisingId
        case appTrackingConsent
        case defaultOption
        case context
    }
    
    @ReadWriteLock private var deviceToken: String?
    @ReadWriteLock private var advertisingId: String?
    @ReadWriteLock private var appTrackingConsent: AppTrackingConsent?
    @ReadWriteLock private var defaultOption: Option?
    @ReadWriteLock private var context: Context?

    func write<T: Any>(_ key: SessionStorage.Keys, value: T?) {
        switch key {
        case .deviceToken:
            deviceToken = value as? String
        case .advertisingId:
            advertisingId = value as? String
        case .appTrackingConsent:
            appTrackingConsent = value as? AppTrackingConsent
        case .defaultOption:
            defaultOption = value as? Option
        case .context:
            if let value = value as? MessageContext, let data = try? JSONSerialization.data(withJSONObject: value) {
                context = try? JSONDecoder().decode(Context.self, from: data)
            }
        }
    }
    
    func read<T: Any>(_ key: SessionStorage.Keys) -> T? {
        var result: T?
        switch key {
        case .deviceToken:
            result = deviceToken as? T
        case .advertisingId:
            result = advertisingId as? T
        case .appTrackingConsent:
            result = appTrackingConsent as? T
        case .defaultOption:
            result = defaultOption as? T
        case .context:
            result = context as? T
        }
        return result
    }
}
