//
//  API+Method.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum Method {
    case post
    case get
    case put
    case delete
    
    var value: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}

extension API {
    var method: Method {
        switch self {
        
        default:
            return .post
        }
    }
}
