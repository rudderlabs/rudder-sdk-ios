//
//  API.swift
//  Rudder
//
//  Created by Pallab Maiti on 05/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum API {
    case flushEvents
}

enum APIClientStatus {
    case success
    case failure
    case serverFailure
    case unknown
    
    init(_ statusCode: Int) {
        switch statusCode {
        case 200..<300:
            self = .success
        case 400..<500:
            self = .failure
        case 500..<600:
            self = .serverFailure
        default:
            self = .unknown
        }
    }
}

extension API {
    var baseURL: String {
        return "/\(version)/"
    }
    
    var version: String {
        return "v1"
    }
}
