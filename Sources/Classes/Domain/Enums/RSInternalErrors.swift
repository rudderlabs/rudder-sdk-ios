//
//  RSInternalErrors.swift
//  Rudder
//
//  Created by Pallab Maiti on 12/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum RSInternalErrors: Error {
    case invalidJSON
    case failedJSONSerialization(Error)
    case maxBatchSize
    
    var description: String {
        switch self {
        case .invalidJSON:
            return "Invalid JSON"
        case .failedJSONSerialization(let error):
                return "JSONSerialization failed. Reason: \(error.localizedDescription)"
        case .maxBatchSize:
            return "Event size exceeds the maximum permitted event size \(MAX_EVENT_SIZE)"
        }
    }
}
