//
//  RSOption.swift
//  RudderStack
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

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
            Logger.log(message: "ExternalId type can not be empty", logLevel: .warning)
            return
        }
        guard id.isNotEmpty else {
            Logger.log(message: "External id can not be empty", logLevel: .warning)
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
            Logger.log(message: "Integration type can not be empty", logLevel: .warning)
            return
        }
        integrations?[type] = enabled
    }
        
    @objc
    public func putCustomContext(_ context: [String: Any], withKey key: String) {
        guard key.isNotEmpty else {
            Logger.log(message: "CustomContext key can not be empty", logLevel: .warning)
            return
        }
        if customContexts == nil {
            customContexts = [String: Any]()
        }
        customContexts?[key] = context
    }
}
