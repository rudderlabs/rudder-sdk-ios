//
//  API+Path.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension API {
    var path: String {
        switch self {
        case .flushEvents:
            return "batch"
        }
    }
}
