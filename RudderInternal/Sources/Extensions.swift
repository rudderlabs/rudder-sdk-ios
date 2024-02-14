//
//  Extensions.swift
//  Rudder
//
//  Created by Pallab Maiti on 11/02/24.
//

import Foundation

public extension Int {
    static func getTimeStamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
}

public extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}

public extension String {
    func getUTF8Length() -> Int {
        return self.data(using: .utf8)?.count ?? 0
    }
    
    func computeAuthToken() -> String? {
        return "\(self):".data(using: .utf8)?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func computeAnonymousIdToken() -> String? {
        return "\(self):".data(using: .utf8)?.base64EncodedString()
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound, range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
    
    var trimmedString: String {
        return trimmingCharacters(in: .whitespaces)
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
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
    
    static func getUniqueId() -> String {
        return NSUUID().uuidString.lowercased()
    }
}
