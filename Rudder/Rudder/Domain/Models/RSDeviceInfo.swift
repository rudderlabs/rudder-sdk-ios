//
//  RSDeviceInfo.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 11/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//
import Foundation
import UIKit


struct RSDeviceInfo {
    let identifier: String?
    let manufacturer: String
    let model: String
    let name: String
    let type: String
    var token: String?
    var adTrackingEnabled: Bool?
    var advertisingId: String?
    var attTrackingStatus: Int
    
    init() {
        identifier = UIDevice.current.identifierForVendor?.uuidString.lowercased()
        manufacturer = "Apple"
        model = UIDevice.current.model
        name = UIDevice.current.name
        type = "iOS"
        attTrackingStatus = RSContext.RSATTNotDetermined
    }
    func dict() -> [String:Any]
    {
        var tempDict : [String:Any] = [:]
        if(identifier != nil)
        {
            tempDict["identifier"] = identifier
        }
        tempDict["manufacturer"] = manufacturer
        tempDict["model"] = model
        tempDict["name"] = name
        tempDict["type"] = type
        if(token != nil)
        {
            tempDict["token"] = token
        }
        if(advertisingId != nil)
        {
            tempDict["adTrackingEnabled"] = adTrackingEnabled
            tempDict["advertisingId"] = advertisingId
        }
        tempDict["attTrackingStatus"] = attTrackingStatus
        return tempDict
    }
}
