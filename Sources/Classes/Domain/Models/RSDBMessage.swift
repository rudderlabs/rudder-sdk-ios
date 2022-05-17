//
//  RSDBMessage.swift
//  RudderStack
//
//  Created by Pallab Maiti on 14/09/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

struct RSDBMessage {
    let messages: [String]
    let messageIds: [String]
    
    init(messages: [String], messageIds: [String]) {
        self.messages = messages
        self.messageIds = messageIds
    }
}
