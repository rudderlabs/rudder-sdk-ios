//
//  RSOption.swift
//  RudderStack
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "This version of the RudderStack iOS SDK is deprecated and is no longer actively maintained. We strongly recommend migrating to our new Swift SDK as soon as possible.")
@objc
open class RSOption: NSObject {
    var externalIds: [[String: String]]?
    var integrations: [String: Bool]?
    var customContexts: [String: Any]?
    
    public override init() {
        externalIds = nil
        integrations = [String: Bool]()
        customContexts = nil
    }
    
    @objc
    public func putExternalId(_ type: String, withId id: String) {
        guard type.isNotEmpty else {
            RSClient.rsLog(message: "ExternalId type can not be empty", logLevel: .warning)
            return
        }
        guard id.isNotEmpty else {
            RSClient.rsLog(message: "External id can not be empty", logLevel: .warning)
            return
        }
        if externalIds == nil {
            externalIds = [[String: String]]()
        }
        if let index = externalIds?.firstIndex(where: { dict in
            return dict["type"] == type
        }) {
            externalIds?[index]["id"] = id
        } else {
            let dict = ["type": type, "id": id]
            externalIds?.append(dict)
        }
    }
    
    @objc
    public func putIntegration(_ type: String, isEnabled enabled: Bool) {
        guard type.isNotEmpty else {
            RSClient.rsLog(message: "Integration type can not be empty", logLevel: .warning)
            return
        }
        integrations?[type] = enabled
    }
        
    @objc
    public func putCustomContext(_ context: [String: Any], withKey key: String) {
        guard key.isNotEmpty else {
            RSClient.rsLog(message: "CustomContext key can not be empty", logLevel: .warning)
            return
        }
        if customContexts == nil {
            customContexts = [String: Any]()
        }
        customContexts?[key] = context
    }
}
