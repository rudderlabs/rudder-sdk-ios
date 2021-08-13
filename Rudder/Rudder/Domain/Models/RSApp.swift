//
//  RSApp.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

struct RSApp {
    let build: String?
    let name: String?
    let nameSpace: String?
    let version: String?
    
    init(){
        let mainBundle = Bundle.main
        self.build = mainBundle.infoDictionary?["CFBundleVersion"] as? String
        self.name = mainBundle.infoDictionary?["CFBundleName"] as? String
        self.nameSpace = mainBundle.bundleIdentifier
        self.version = mainBundle.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    func dict() -> [String:String]
    {
        var tempDict : [String:String] = [:]
        if(build != nil)
        {
            tempDict["build"] = build
        }
        if(name != nil)
        {
            tempDict["name"] = name
        }
        if(nameSpace != nil)
        {
            tempDict["namespace"] = nameSpace
        }
        if(version != nil)
        {
            tempDict["version"] = version
        }
        return tempDict
    }
}
