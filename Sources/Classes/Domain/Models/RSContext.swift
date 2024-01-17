//
//  RSContext.swift
//  Rudder
//
//  Created by Pallab Maiti on 07/12/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc
open class RSContext: NSObject, Codable {
    @objc
    open class AppInfo: NSObject, Codable {
        public var name: String
        public var namespace: String
        public var build: String
        public var version: String
        
        internal override init() {
            let info = Bundle.main.infoDictionary
            name = (info?["CFBundleDisplayName"] as? String ?? (info?["CFBundleName"] as? String)) ?? ""
            version = (info?["CFBundleShortVersionString"] as? String) ?? ""
            build = (info?["CFBundleVersion"] as? String) ?? ""
            namespace = (Bundle.main.bundleIdentifier) ?? ""
        }
    }
    
    @objc
    open class DeviceInfo: NSObject, Codable {
        public var id: String?
        public var manufacturer: String?
        public var model: String?
        public var name: String?
        public var type: String?
        
        internal override init() {
            manufacturer = Vendor.current.manufacturer
            type = Vendor.current.type
            model = Vendor.current.model
            name = Vendor.current.name
            id = Vendor.current.identifierForVendor
        }
    }
    
    @objc
    open class LibraryInfo: NSObject, Codable {
        public var name: String
        public var version: String
        
        internal override init() {
            name = "rudder-ios-library"
            version = RSVersion
        }
    }
    
    @objc
    open class OSInfo: NSObject, Codable {
        public var name: String?
        public var version: String?
        
        internal override init() {
            name = Vendor.current.systemName
            version = Vendor.current.systemVersion
        }
    }
    
    @objc
    open class ScreenInfo: NSObject, Codable {
        public var density: Double?
        public var width: Double?
        public var height: Double?
        
        internal override init() {
            width = Vendor.current.screenSize.width
            height = Vendor.current.screenSize.height
            density = Vendor.current.screenSize.density
        }
    }
    
    @objc
    open class NetworkInfo: NSObject, Codable {
        public var carrier: String?
        public var bluetooth: Bool = false
        public var cellular: Bool = false
        public var wifi: Bool = false
        
        internal override init() {
            switch Vendor.current.connection {
            case .online(.cellular):
                cellular = true
            case .online(.wifi):
                wifi = true
            case .online(.bluetooth):
                bluetooth = true
            default:
                break
            }
            carrier = Vendor.current.carrier
        }
    }
    
    private let _app: AppInfo?
    public var app: AppInfo? {
        _app
    }
    
    private let _device: DeviceInfo?
    public var device: DeviceInfo? {
        _device
    }
    
    private let _library: LibraryInfo?
    public var library: LibraryInfo? {
        _library
    }
    
    private let _os: OSInfo?
    public var os: OSInfo? {
        _os
    }
    
    private let _screen: ScreenInfo?
    public var screen: ScreenInfo? {
        _screen
    }
    
    private let _locale: String?
    public var locale: String? {
        _locale
    }
    
    private let _network: NetworkInfo?
    public var network: NetworkInfo? {
        _network
    }
    
    private let _timezone: String?
    public var timezone: String? {
        _timezone
    }
    
    private let _traits: JSON?
    public var traits: IdentifyTraits? {
        _traits?.dictionaryValue
    }
    
    private let _externalIds: [[String: String]]?
    public var externalIds: [[String: String]]? {
        _externalIds
    }
    
    public var dictionaryValue: [String: Any]? {
        return self.dictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case _app = "app"
        case _device = "device"
        case _library = "library"
        case _os = "os"
        case _screen = "screen"
        case _locale = "locale"
        case _network = "network"
        case _timezone = "timezone"
        case _traits = "traits"
        case _externalIds = "externalId"
    }
    
    static func locale() -> String {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            return "\(Locale.current.language.languageCode?.identifier ?? "")-\(Locale.current.region?.identifier ?? "")"
        } else {
            return "\(Locale.current.languageCode ?? "")-\(Locale.current.regionCode ?? "")"
        }
    }
    
    static func timezone() -> String {
        return TimeZone.current.identifier
    }
    
    static func traits(userDefaults: RSUserDefaults?) -> JSON? {
        let traitsJSON: JSON? = userDefaults?.read(.traits)
        var traitsDict = traitsJSON?.dictionaryValue
        if let userId: String = userDefaults?.read(.userId) {
            traitsDict?["userId"] = userId
        }
        if let anonymousId: String = userDefaults?.read(.anonymousId) {
            traitsDict?["anonymousId"] = anonymousId
        }
        if let traits = traitsDict {
            return try? JSON(traits)
        }
        return nil
    }
    
    internal init(userDefaults: RSUserDefaults?) {
        _app = AppInfo()
        _device = DeviceInfo()
        _library = LibraryInfo()
        _os = OSInfo()
        _screen = ScreenInfo()
        _locale = Self.locale()
        _network = NetworkInfo()
        _timezone = Self.timezone()
        _traits = Self.traits(userDefaults: userDefaults)
        _externalIds = userDefaults?.read(.externalId)
    }
}

public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
