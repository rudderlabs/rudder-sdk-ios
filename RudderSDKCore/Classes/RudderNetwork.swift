//
//  RudderNetwork.swift
//  RudderSample
//
//  Created by Arnab Pal on 12/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation
import CoreTelephony
import SystemConfiguration.CaptiveNetwork

class RudderNetwork: Encodable {
    var carrier: String = ""
    var bluetooth: Bool  = false
    var cellular: Bool = false
    var wifi: Bool = false
    
    init() {
        self.carrier = CTCarrier().carrierName ?? "unavailable"
        self.cellular = self.carrier != "unavailable"
        self.wifi = self.isWifiEnabled()
    }
    
    private func isWifiEnabled() -> Bool {
        var hasWiFiNetwork: Bool = false
        let interfaces: NSArray? = CFBridgingRetain(CNCopySupportedInterfaces()) as? NSArray
        if (interfaces == nil) {
            return false
        }
        
        for interface  in interfaces! {
            let networkInfo: [AnyHashable: Any]? = CFBridgingRetain(CNCopyCurrentNetworkInfo(((interface) as! CFString))) as? [AnyHashable : Any]
            if (networkInfo != nil) {
                hasWiFiNetwork = true
                break
            }
        }
        return hasWiFiNetwork;
    }
}
