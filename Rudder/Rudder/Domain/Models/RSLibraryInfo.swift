//
//  RSLibraryInfo.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

struct RSLibraryInfo{
    let name: String
    let version: String
    
    init() {
        name = "rudder_ios_library"
        version = Constants.RS_VERSION
    }
    
    func dict() -> [String:String]
    {
        var tempDict:[String:String] = [:]
        tempDict["name"] = name
        tempDict["version"] = version
        return tempDict
    }
}
