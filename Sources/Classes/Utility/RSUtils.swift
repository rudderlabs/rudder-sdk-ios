//
//  RSUtils.swift
//  RudderStack
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import SQLite3

struct RSUtils {
    static func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: date)
    }
    
    static func getTimestampString() -> String {
        return getDateString(date: Date())
    }

    static func getDBPath() -> String {
        let urlDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        let fileUrl = urlDirectory.appendingPathComponent("rl_persistence.sqlite")
        return fileUrl.path
    }
    
    static func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        if sqlite3_open_v2(getDBPath(), &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            return db
        } else {
            return nil
        }
    }

    static func getTimeStamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }

    static func getUniqueId() -> String {
        return NSUUID().uuidString.lowercased()
    }

    static func getLocale() -> String {
        let locale = Locale.current
        if #available(iOS 10.0, *) {
            return String(format: "%@-%@", locale.languageCode!, locale.regionCode!)
        }
        return "NA"
    }
    
    static func getJSON(from message: RSDBMessage) -> String {
        let sentAt = RSUtils.getTimestampString()
        var jsonString = "{\"sentAt\":\"\(sentAt)\",\"batch\":["
        var totalBatchSize = jsonString.getUTF8Length() + 2
        var index = 0
        for message in message.messages {
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
    
    static func getLifeCycleProperties(previousVersion: String? = nil, previousBuild: String? = nil, currentVersion: String? = nil, currentBuild: String? = nil, fromBackground: Bool? = nil, referringApplication: Any? = nil, url: Any? = nil) -> [String: Any] {
        var properties = [String: Any]()
        if let previousVersion = previousVersion, previousVersion.isNotEmpty {
            properties["previous_version"] = previousVersion
        }
        if let previousBuild = previousBuild, previousBuild.isNotEmpty {
            properties["previous_build"] = previousBuild
        }
        if let currentVersion = currentVersion, currentVersion.isNotEmpty {
            properties["version"] = currentVersion
        }
        if let currentBuild = currentBuild, currentBuild.isNotEmpty {
            properties["build"] = currentBuild
        }
        if let fromBackground = fromBackground {
            properties["from_background"] = fromBackground
        }
        if let referringApplication = referringApplication {
            properties["referring_application"] = referringApplication
        }
        if let url = url {
            properties["url"] = url
        }
        return properties
    }
}
