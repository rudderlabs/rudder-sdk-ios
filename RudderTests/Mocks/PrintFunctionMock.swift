//
//  PrintFunctionMock.swift
//  Rudder
//
//  Created by Pallab Maiti on 07/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class PrintFunctionMock {
    var printedMessages: [String] = []
    var printedMessage: String? { printedMessages.last }
    
    init() { }
    
    func print(message: String) {
        printedMessages.append(message)
    }
    
    func reset() {
        printedMessages = []
    }
}
