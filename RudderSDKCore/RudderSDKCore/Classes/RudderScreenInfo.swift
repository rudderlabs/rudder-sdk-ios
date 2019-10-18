//
//  RudderScreenInfo.swift
//  RudderSample
//
//  Created by Arnab Pal on 12/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation
import UIKit

struct RudderScreenInfo: Encodable {
    var density: Int
    var width: Int
    var height: Int
    
    init() {
        let screenSize = UIScreen.main.bounds
        self.width = Int(screenSize.width)
        self.height = Int(screenSize.height)
        self.density = Int(UIScreen.main.scale)
    }
    
    enum CodingKeys: String, CodingKey {
        case density = "density"
        case width = "width"
        case height = "height"
    }
}
