//
//  RudderServerDestinationDefinition.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 11/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

class RudderServerDestinationDefinition : Decodable {
    var name: String
    var displayName: String
    var updatedAt: String
}
