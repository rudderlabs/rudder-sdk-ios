//
//  RSNetwork.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import CoreTelephony


struct RSNetwork {
    
    let carrier: String
    let wifi: Bool
    let bluetooth: Bool
    let cellular: Bool
    
    init() {
        self.carrier = CTCarrier.init().carrierName ?? "unavailable";
        self.wifi = true
        self.bluetooth = false
        self.cellular = false
    }
    
    func dict() -> [String:Any]
    {
        var tempDict : [String : Any] = [:]
        tempDict["carrier"] = carrier
        tempDict["wifi"] = wifi
        tempDict["bluetooth"] = bluetooth
        tempDict["cellular"] = cellular
        return tempDict
    }
}
