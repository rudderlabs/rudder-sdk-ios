//
//  RSScreenInfo.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

struct RSScreenInfo {
    let density: Int
    let width: Int
    let height: Int
    
    init() {
        
        let bounds = UIScreen.main.bounds
        density = Int(UIScreen.main.scale)
        height = Int(bounds.size.width)
        width = Int(bounds.size.height)
    }
    
    func dict() -> [String:Int]
    {
        var tempDict:[String:Int] = [:]
        tempDict["density"] = density
        tempDict["height"] = height
        tempDict["width"] = width
        return tempDict
    }
}
