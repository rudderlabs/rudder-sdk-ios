//
//  InternalErrors.swift
//  Rudder
//
//  Created by Pallab Maiti on 12/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public enum InternalErrors: Error {
    case invalidJSON
    case failedJSONSerialization(Error)
    case maxBatchSize(Int)
    
    public var description: String {
        switch self {
        case .invalidJSON:
            return "Invalid JSON"
        case .failedJSONSerialization(let error):
                return "JSONSerialization failed. Reason: \(error.localizedDescription)"
        case .maxBatchSize(let size):
            return "Event size exceeds the maximum permitted event size \(size)"
        }
    }
}
