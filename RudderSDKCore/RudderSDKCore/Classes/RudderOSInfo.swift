//
//  RudderOSInfo.swift
//  RudderSample
//
//  Created by Arnab Pal on 12/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation
import UIKit

struct RudderOSInfo: Encodable {
    var name: String = UIDevice.current.systemName
    var version: String = UIDevice.current.systemVersion
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case version = "version"
    }
}
