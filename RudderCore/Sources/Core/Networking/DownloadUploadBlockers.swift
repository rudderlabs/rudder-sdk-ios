//
//  DownloadUploadBlockers.swift
//  Rudder
//
//  Created by Pallab Maiti on 15/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

enum Blocker {
    case networkReachability(description: String)
}

protocol DownloadUploadBlockersProtocol {
    func get() -> [Blocker]
}

class DownloadUploadBlockers: DownloadUploadBlockersProtocol {
    #if !os(watchOS)
    let reachability = try? Reachability()
    #endif
    
    func get() -> [Blocker] {
        #if !os(watchOS)
        if let reachability = reachability, reachability.connection == .unavailable {
            return [.networkReachability(description: reachability.connection.description)]
        }
        #endif
        return []
    }
}
