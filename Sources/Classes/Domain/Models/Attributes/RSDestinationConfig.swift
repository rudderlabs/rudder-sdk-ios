//
//  RSDestinationConfig.swift
//  RudderStack
//
//  Created by Pallab Maiti on 19/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public class RSDestinationConfig: NSObject, Codable {    
    struct Config: Codable {
        let ios: [String]?
        let unity: [String]?
        let android: [String]?
        let reactnative: [String]?
        let defaultConfig: [String]?
    }
    
    private let _destConfig: Config?
    public var ios: [String]? {
        return _destConfig?.ios
    }
    
    public var unity: [String]? {
        return _destConfig?.unity
    }
    
    public var android: [String]? {
        return _destConfig?.android
    }
    
    public var reactnative: [String]? {
        return _destConfig?.reactnative
    }
    
    public var defaultConfig: [String]? {
        return _destConfig?.defaultConfig
    }
    
    public let secretKeys: [String]?
    public let excludeKeys: [String]?
    public let includeKeys: [String]?
    
    private let _transformAt: String?
    public var transformAt: String {
        return _transformAt ?? ""
    }
    
    private let _transformAt1: String?
    public var transformAt1: String {
        return _transformAt1 ?? ""
    }
    
    public let supportedSourceTypes: [String]?
    
    private let _saveDestinationResponse: Bool?
    public var saveDestinationResponse: Bool {
        return _saveDestinationResponse ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case _destConfig = "config"
        case secretKeys, excludeKeys, includeKeys, supportedSourceTypes
        case _transformAt = "transformAt"
        case _transformAt1 = "transformAt1"
        case _saveDestinationResponse = "saveDestinationResponse"
    }
}
