//
//  RSDestinationDefinition.swift
//  RudderStack
//
//  Created by Pallab Maiti on 17/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public class RSDestinationDefinition: NSObject, Codable {
    
    struct Config: Codable {
        let config: RSDestinationConfig?
        
        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case config
        }
    }
    
    private let _id: String?
    public var id: String {
        return _id ?? ""
    }
    
    private let _name: String?
    public var name: String {
        return _name ?? ""
    }    
    
    private let _displayName: String?
    public var displayName: String {
        return _displayName ?? ""
    }
    
    private let _createdAt: String?
    public var createdAt: String {
        return _createdAt ?? ""
    }
    
    private let _updatedAt: String?
    public var updatedAt: String {
        return _updatedAt ?? ""
    }
    
    private let _destinationConfig: Config?
    public var destinationConfig: RSDestinationConfig? {
        return _destinationConfig?.config
    }
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _displayName = "displayName"
        case _createdAt = "createdAt"
        case _updatedAt = "updatedAt"
        case _destinationConfig = "config"
    }
}
