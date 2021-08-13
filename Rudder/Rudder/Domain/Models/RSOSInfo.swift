//
//  RSOSInfo.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

struct RSOSInfo {
    let name: String
    let version: String
    
    init() {
        name = UIDevice.current.systemName
        version = UIDevice.current.systemVersion
    }
    
    func dict() -> [String : String]
    {
        var tempDict: [String:String] = [:]
        tempDict["name"] = name
        tempDict["version"] = version
        return tempDict
    }
}
