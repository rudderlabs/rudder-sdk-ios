//
//  SourceConfigMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 25/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
@testable import Rudder

extension SourceConfig {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        source: SourceConfig.Source? = .mockAny()
    ) -> Self {
        .init(source: source)
    }
}

extension SourceConfig.Source {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        id: String? = .mockRandom(among: .alphanumerics, length: 27),
        name: String? = .mockRandom(among: .custom(characters: "iOS Dev")),
        writeKey: String? = .mockRandom(among: .alphanumerics, length: 27),
        enabled: Bool? = .mockAny(),
        sourceDefinitionId: String? = .mockRandom(among: .alphanumerics, length: 27),
        createdBy: String? = .mockAnyDate(),
        workspaceId: String? = .mockRandom(among: .alphanumerics, length: 27),
        deleted: Bool? = .mockAny(),
        createdAt: String? = .mockAnyDate(),
        updatedAt: String? = .mockAnyDate(),
        destinations: [Destination]? = [.mockAny()],
        dataPlanes: DataPlanes? = .mockAny()
    ) -> Self {
        .init(id: id, name: name, writeKey: writeKey, enabled: enabled, sourceDefinitionId: sourceDefinitionId, createdBy: createdBy, workspaceId: workspaceId, deleted: deleted, createdAt: createdAt, updatedAt: updatedAt, destinations: destinations, dataPlanes: dataPlanes)
    }
}

extension SourceConfig.Source.DataPlanes {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        eu: [DataPlane]? = [.mockAny()],
        us: [DataPlane]? = [.mockAny()]
    ) -> Self {
        .init(eu: eu, us: us)
    }
}

extension SourceConfig.Source.DataPlanes.DataPlane {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        url: String? = .mockAnyURL(),
        default: Bool? = .mockAny()
    ) -> Self {
        .init(url: url, default: `default`)
    }
}

extension Destination {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        config: JSON? = nil,
        secretConfig: JSON? = nil,
        id: String? = .mockRandom(among: .alphanumerics, length: 27),
        name: String? = .mockRandom(among: .custom(characters: "Destination")),
        enabled: Bool? = .mockAny(),
        workspaceId: String? = .mockRandom(among: .alphanumerics, length: 27),
        deleted: Bool? = .mockAny(),
        createdAt: String? = .mockAnyDate(),
        updatedAt: String? = .mockAnyDate(),
        destinationDefinition: DestinationDefinition = .mockAny()
    ) -> Self {
        .init(config: config, secretConfig: secretConfig, id: id, name: name, enabled: enabled, workspaceId: workspaceId, deleted: deleted, createdAt: createdAt, updatedAt: updatedAt, destinationDefinition: destinationDefinition)
    }
}

extension DestinationDefinition.Config {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        config: DestinationConfig? = .mockAny()
    ) -> Self {
        .init(config: config)
    }
}

extension DestinationDefinition {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        id: String? = .mockRandom(among: .alphanumerics, length: 27),
        name: String? = .mockRandom(among: .custom(characters: "DestinationDefinition")),
        displayName: String? = .mockRandom(among: .custom(characters: "DEST")),
        createdAt: String? = .mockAnyDate(),
        updatedAt: String? = .mockAnyDate(),
        destinationConfig: Config? = .mockAny()
    ) -> Self {
        .init(id: id, name: name, displayName: displayName, createdAt: createdAt, updatedAt: updatedAt, destinationConfig: destinationConfig)
    }
}

extension DestinationConfig.Config {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        ios: [String]? = [.mockRandom(among: .custom(characters: "useNativeSDK"))],
        unity: [String]? = [.mockRandom(among: .custom(characters: "useNativeSDK"))],
        android: [String]? = [.mockRandom(among: .custom(characters: "useNativeSDK"))],
        reactnative: [String]? = [.mockRandom(among: .custom(characters: "useNativeSDK"))],
        defaultConfig: [String]? = .mockAny()
    ) -> Self {
        .init(ios: ios, unity: unity, android: android, reactnative: reactnative, defaultConfig: defaultConfig)
    }
}

extension DestinationConfig {
    static func mockAny() -> Self {
        .mockWith()
    }
    
    static func mockWith(
        destConfig: Config? = .mockAny(),
        secretKeys: [String]? = .mockAny(),
        excludeKeys: [String]? = .mockAny(),
        includeKeys: [String]? = .mockAny(),
        transformAt: String? = .mockAny(),
        transformAt1: String? = .mockAny(),
        supportedSourceTypes: [String]? = .mockAny(),
        saveDestinationResponse: Bool? = .mockAny()
    ) -> Self {
        .init(destConfig: destConfig, secretKeys: secretKeys, excludeKeys: excludeKeys, includeKeys: includeKeys, transformAt: transformAt, transformAt1: transformAt1, supportedSourceTypes: supportedSourceTypes, saveDestinationResponse: saveDestinationResponse)
    }
}
