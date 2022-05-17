//
//  String+Ext.swift
//  RudderStack
//
//  Created by Pallab Maiti on 10/09/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

extension String {
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
}
