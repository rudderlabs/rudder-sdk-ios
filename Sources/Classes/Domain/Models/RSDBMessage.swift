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

extension RSDBMessage {
    func toJSONString() -> String {
        let sentAt = RSUtils.getTimestampString()
        var jsonString = "{\"sentAt\":\"\(sentAt)\",\"batch\":["
        var totalBatchSize = jsonString.getUTF8Length() + 2
        var index = 0
        for message in self.messages {
            var string = message[0..<message.count - 1]
            string += ",\"sentAt\":\"\(sentAt)\"},"
            totalBatchSize += string.getUTF8Length()
            if totalBatchSize > MAX_BATCH_SIZE {
                break
            }
            jsonString += string
            index += 1
        }
        if jsonString.last == "," {
            jsonString = String(jsonString.dropLast())
        }
        jsonString += "]}"
        return jsonString
    }
}
