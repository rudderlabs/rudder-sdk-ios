//
//  API+Headers.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension API {
    var headers: [String: String]? {
        let headers = ["Content-Type": "Application/json"]       
        return headers
    }
}
