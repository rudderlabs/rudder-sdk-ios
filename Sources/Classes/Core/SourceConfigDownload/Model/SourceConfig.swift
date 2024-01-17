//
//  SourceConfig.swift
//  Rudder
//
//  Created by Pallab Maiti on 19/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

// swiftlint:disable nesting
public struct SourceConfig: Codable, Equatable {
    struct Source: Codable, Equatable {
        struct DataPlanes: Codable, Equatable {
            struct DataPlane: Codable, Equatable {
                private let _url: String?
                var url: String {
                    return _url ?? ""
                }
                
                private let _default: Bool?
                var `default`: Bool {
                    return _default ?? false
                }
                
                init(url: String?, default: Bool?) {
                    self._url = url
                    self._default = `default`
                }
                
                enum CodingKeys: String, CodingKey {
                    case _url = "url"
                    case _default = "default"
                }
            }
            
            let eu: [DataPlane]?
            let us: [DataPlane]?
            
            init(eu: [DataPlane]?, us: [DataPlane]?) {
                self.eu = eu
                self.us = us
            }
            
            enum CodingKeys: String, CodingKey {
                case eu = "EU"
                case us = "US"
            }
        }

        private let _id: String?
        var id: String {
            return _id ?? ""
        }
        
        private let _name: String?
        var name: String {
            return _name ?? ""
        }
        
        private let _writeKey: String?
        var writeKey: String {
            return _writeKey ?? ""
        }
        
        private let _enabled: Bool?
        var enabled: Bool {
            return _enabled ?? false
        }
        
        private let _sourceDefinitionId: String?
        var sourceDefinitionId: String {
            return _sourceDefinitionId ?? ""
        }
        
        private let _createdBy: String?
        var createdBy: String {
            return _createdBy ?? ""
        }
        
        private let _workspaceId: String?
        var workspaceId: String {
            return _workspaceId ?? ""
        }
        
        private let _deleted: Bool?
        var deleted: Bool {
            return _deleted ?? false
        }
        
        private let _createdAt: String?
        var createdAt: String {
            return _createdAt ?? ""
        }
        
        private let _updatedAt: String?
        var updatedAt: String {
            return _updatedAt ?? ""
        }
        
        let destinations: [Destination]?
        let dataPlanes: DataPlanes?
        
        init(
            id: String?,
            name: String?,
            writeKey: String?,
            enabled: Bool?,
            sourceDefinitionId: String?,
            createdBy: String?,
            workspaceId: String?,
            deleted: Bool?,
            createdAt: String?,
            updatedAt: String?,
            destinations: [Destination]?,
            dataPlanes: DataPlanes?
        ) {
            self._id = id
            self._name = name
            self._writeKey = writeKey
            self._enabled = enabled
            self._sourceDefinitionId = sourceDefinitionId
            self._createdBy = createdBy
            self._workspaceId = workspaceId
            self._deleted = deleted
            self._createdAt = createdAt
            self._updatedAt = updatedAt
            self.destinations = destinations
            self.dataPlanes = dataPlanes
        }
        
        enum CodingKeys: String, CodingKey {
            case _id = "id"
            case _name = "name"
            case _writeKey = "writeKey"
            case _enabled = "enabled"
            case _sourceDefinitionId = "sourceDefinitionId"
            case _createdBy = "createdBy"
            case _workspaceId = "workspaceId"
            case _deleted = "deleted"
            case _createdAt = "createdAt"
            case _updatedAt = "updatedAt"
            case destinations = "destinations"
            case dataPlanes = "dataplanes"
        }
    }

    internal let source: Source?
    
    public var id: String {
        return source?.id ?? ""
    }
    
    public var name: String {
        return source?.name ?? ""
    }
    
    public var writeKey: String {
        return source?.writeKey ?? ""
    }
    
    public var enabled: Bool {
        return source?.enabled ?? false
    }
    
    public var sourceDefinitionId: String {
        return source?.sourceDefinitionId ?? ""
    }
    
    public var createdBy: String {
        return source?.createdBy ?? ""
    }
    
    public var workspaceId: String {
        return source?.workspaceId ?? ""
    }
    
    public var deleted: Bool {
        return source?.deleted ?? false
    }
    
    public var createdAt: String {
        return source?.createdAt ?? ""
    }
    
    public var updatedAt: String {
        return source?.updatedAt ?? ""
    }
    
    public var destinations: [Destination]? {
        return source?.destinations
    }
}

extension SourceConfig {
    public func getDestination(by key: String) -> Destination? {
        if let destinations = destinations, let destination = destinations.first(where: { $0.destinationDefinition?.displayName == key }) {
            return destination
        }
        return nil
    }
    
    private func getConfig<T: Codable>(forKey key: String) -> T? {
        var result: T?
        if let destination = getDestination(by: key) {
            guard let config = destination.config?.dictionaryValue else { return nil }
            if let jsonData = try? JSONSerialization.data(withJSONObject: config) {
                result = try? JSONDecoder().decode(T.self, from: jsonData)
            }
        }
        return result
    }
    
    public func getConfig<T: Codable>(forPlugin plugin: DestinationPlugin) -> T? {
        return getConfig(forKey: plugin.name)
    }
}
