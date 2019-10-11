//
//  RudderServerConfigSource.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 11/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

class RudderServerConfigSource : Decodable {
    var config: String? = nil
    var id: String = ""
    var name: String = ""
    var enabled: Bool = false
    var updatedAt: String = ""
    var destinations: [RudderServerDestination] = []
}
