//
//  RSMessageEntity.swift
//  Rudder
//
//  Created by Pallab Maiti on 14/09/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public struct StorageMessage {
    public let id: String
    public let message: String
    public let updated: Int
    
    public init(id: String, message: String, updated: Int) {
        self.id = id
        self.message = message
        self.updated = updated
    }
}

extension [StorageMessage] {
    func toJSONString() -> String {
        let sentAt = Utility.getTimestampString()
        var jsonString = "{\"sentAt\":\"\(sentAt)\",\"batch\":["
        var totalBatchSize = jsonString.getUTF8Length() + 2
        for entity in self {
            var string = entity.message[0..<entity.message.count - 1]
            string += ",\"sentAt\":\"\(sentAt)\"},"
            totalBatchSize += string.getUTF8Length()
            if totalBatchSize > Constants.batchSize.default {
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
