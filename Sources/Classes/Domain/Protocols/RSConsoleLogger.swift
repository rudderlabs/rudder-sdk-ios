//
//  RSConsoleLogger.swift
//  RudderStack
//
//  Created by Pallab Maiti on 24/02/22.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class RSConsoleLogger: RSLogger {
    func parseLog(_ log: RSLogMessage) {
        var metadata = ""
        if let function = log.function, let line = log.line {
            metadata = " - \(function):\(line)"
        }
        print("\(TAG):\(log.logLevel.toString()):\(metadata):\(log.message)")
    }
}
