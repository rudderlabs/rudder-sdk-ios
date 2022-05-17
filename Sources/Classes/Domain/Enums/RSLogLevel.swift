//
//  RSLogLevel.swift
//  RudderStack
//
//  Created by Pallab Maiti on 10/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

@frozen @objc public enum RSLogLevel: Int {
    case verbose = 5
    case debug = 4
    case info = 3
    case warning = 2
    case error = 1
    case `none` = 0
    
    public func toString() -> String {
        switch self {
        case .verbose:
            return "Verbose"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .none:
            return ""
        }
    }
}
