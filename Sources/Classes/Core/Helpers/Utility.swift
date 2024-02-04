//
//  RSUtils.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 06/08/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class Utility {
    static func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: date)
    }
    
    static func getTimestampString() -> String {
        return getDateString(date: Date())
    }

    static func getTimeStamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }

    static func getUniqueId() -> String {
        return NSUUID().uuidString.lowercased()
    }

    static func getLifeCycleProperties(previousVersion: String? = nil,
                                       previousBuild: String? = nil,
                                       currentVersion: String? = nil,
                                       currentBuild: String? = nil,
                                       fromBackground: Bool? = nil,
                                       referringApplication: Any? = nil,
                                       url: Any? = nil) -> [String: Any] {
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
