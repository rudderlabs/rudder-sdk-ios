//
//  RSOption.swift
//  Rudder
//
//  Created by Pallab Maiti on 04/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@objc open class RSOption: NSObject {
    var externalIds: [[String: Any]]?
    var integrations: [String: Any]
    var customContexts: [String: Any]?
    
    public override init() {
        externalIds = nil
        integrations = [String: Any]()
        customContexts = nil
    }
    
    func putExternalId(type: String, withId idValue: String) {
        if externalIds == nil {
            externalIds = [[String: Any]]()
        }
        var dictIndex: Int = -1
        var externalIdDict: [String: Any]?
        if let externalIds = externalIds {
            for index in 0..<externalIds.count {
                let dict = externalIds[index]
                if let dictType = dict["type"] as? String, dictType == type {
                    externalIdDict = dict
                    dictIndex = index
                    break
                }
            }
        }
        if externalIdDict == nil {
            externalIdDict = ["type": type]
        }
        externalIdDict?["id"] = idValue
        if dictIndex == -1 {
            if let externalIdDict = externalIdDict {
                externalIds?.append(externalIdDict)
            }
        } else {
            externalIds?[dictIndex]["id"] = idValue
        }
    }
    
    @objc public func putIntegration(_ type: String, isEnabled enabled: Bool) {
        integrations[type] = enabled
    }
    
    func putIntegrationWithFactory(factory: RSIntegrationFactory, isEnabled enabled: Bool) {
        integrations[factory.key] = enabled
    }
    
    @objc public func putCustomContext(_ context: [String: Any]?, withKey key: String?) {
        if customContexts == nil {
            customContexts = [String: Any]()
        }
        if let key = key, let context = context {
            customContexts?[key] = context
        }
    }
}
