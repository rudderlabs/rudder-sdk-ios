//
//  RSMessageEntity.swift
//  RudderStack
//
//  Created by Pallab Maiti on 14/09/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public struct RSMessageEntity {
    let id: String
    let message: String
    
    init(id: String, message: String) {
        self.id = id
        self.message = message
    }
}

extension [RSMessageEntity] {
    func toJSONString() -> String {
        let sentAt = RSUtils.getTimestampString()
        var jsonString = "{\"sentAt\":\"\(sentAt)\",\"batch\":["
        var totalBatchSize = jsonString.getUTF8Length() + 2
        for entity in self {
            var string = entity.message[0..<entity.message.count - 1]
            string += ",\"sentAt\":\"\(sentAt)\"},"
            totalBatchSize += string.getUTF8Length()
            if totalBatchSize > MAX_BATCH_SIZE {
                break
            }
            jsonString += string
        }
        if jsonString.last == "," {
            jsonString = String(jsonString.dropLast())
        }
        jsonString += "]}"
        return jsonString
    }
}
