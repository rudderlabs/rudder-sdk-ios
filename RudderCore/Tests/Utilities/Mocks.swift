//
//  Mocks.swift
//  Rudder
//
//  Created by Pallab Maiti on 24/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol AnyMockable {
    static func mockAny() -> Self
}

public protocol RandomMockable {
    static func mockRandom() -> Self
}

extension String: AnyMockable, RandomMockable {
    public static func mockAny() -> String {
        return "abc"
    }
    
    public static func mockRandom() -> String {
        return mockRandom(length: 10)
    }
    
    public static func mockRandom(length: Int) -> String {
        return mockRandom(among: .alphanumerics, length: length)
    }
    
    public static func mockRandom(among characters: RandomStringCharacterSet, length: Int = 10) -> String {
        return characters.random(ofLength: length)
    }
    
    public enum RandomStringCharacterSet {
        private static let alphanumericCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        private static let decimalDigitCharacters = "0123456789"
        
        case alphanumerics
        case decimalDigits
        case custom(characters: String)
        
        func random(ofLength length: Int) -> String {
            var characters: String
            switch self {
            case .alphanumerics:
                characters = RandomStringCharacterSet.alphanumericCharacters
            case .decimalDigits:
                characters = RandomStringCharacterSet.decimalDigitCharacters
            case .custom(let customCharacters):
                characters = customCharacters
            }
            
            return String((0..<length).map { _ in characters.randomElement()! })
        }
    }
    
    public static func mockAnyDate() -> String {
        return mockRamdomDate(.mockAny())
    }
    
    public static func mockRamdomDate(_ date: Date = .mockAny()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: date)
    }
    
    public static func mockAnyURL() -> String {
        return mockRamdomURL(.mockAny())
    }
    
    public static func mockRamdomURL(_ url: URL = .mockAny()) -> String {
        return url.absoluteString
    }
    
    public static func mockAnyDictionary() -> String {
        let dictionary: [String: String] = [
            .mockRandom(length: 5): .mockRandom(length: 10)
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8)!
    }
}

extension Int: AnyMockable, RandomMockable { }
extension UInt32: AnyMockable, RandomMockable { }
extension UInt8: AnyMockable, RandomMockable { }

extension ExpressibleByIntegerLiteral where Self: AnyMockable {
    public static func mockAny() -> Self { 0 }
}

extension FixedWidthInteger where Self: RandomMockable {
    public static func mockRandom() -> Self {
        return .random(in: min...max)
    }
    
    public static func mockRandom(min: Self = .min, max: Self = .max, otherThan values: Set<Self> = []) -> Self {
        var random: Self = .random(in: min...max)
        while values.contains(random) { random = .random(in: min...max) }
        return random
    }
}

extension Bool: AnyMockable {
    public static func mockAny() -> Bool {
        return false
    }
}

extension URL: AnyMockable, RandomMockable {
    public static func mockAny() -> URL {
        return URL(string: "https://www.rudder.com")!
    }
    
    public static func mockWith(
        url: String,
        queryParams: [URLQueryItem]? = nil
    ) -> URL {
        var urlComponents = URLComponents(string: url)
        urlComponents!.queryItems = queryParams
        return urlComponents!.url!
    }
    
    public static func mockRandom() -> URL {
        return URL(string: "https://www.rudder.com/")!
            .appendingPathComponent(
                .mockRandom(
                    among: .alphanumerics,
                    length: 32
                )
            )
    }
}

extension Array: AnyMockable where Element: AnyMockable {
    public static func mockAny() -> [Element] {
        return (0..<10).map { _ in .mockAny() }
    }
    
    public static func mockAny(count: Int) -> [Element] {
        return (0..<count).map { _ in .mockAny() }
    }
}

extension Array: RandomMockable where Element: RandomMockable {
    public static func mockRandom() -> [Element] {
        return (0..<10).map { _ in .mockRandom() }
    }
    
    public static func mockRandom(count: Int) -> [Element] {
        return (0..<count).map { _ in .mockRandom() }
    }
}

extension Dictionary: AnyMockable where Key: AnyMockable, Value: AnyMockable {
    public static func mockAny() -> Dictionary {
        return [Key.mockAny(): Value.mockAny()]
    }
}

extension Dictionary: RandomMockable where Key: RandomMockable, Value: RandomMockable {
    public static func mockRandom() -> Dictionary {
        return [Key.mockRandom(): Value.mockRandom()]
    }
}

extension Date: AnyMockable, RandomMockable {
    public static func mockAny() -> Date {
        return Date(timeIntervalSinceReferenceDate: 1)
    }
    
    public static func mockRandom() -> Date {
        let randomTimeInterval = TimeInterval.random(in: 0..<Date().timeIntervalSince1970)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    public static func mockRandomInThePast() -> Date {
        return Date(timeIntervalSinceReferenceDate: TimeInterval.mockRandomInThePast())
    }
    
    public static func mockSpecificUTCGregorianDate(year: Int, month: Int, day: Int, hour: Int, minute: Int = 0, second: Int = 0) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.timeZone = .UTC
        dateComponents.calendar = .gregorian
        return dateComponents.date!
    }
}

extension TimeZone: AnyMockable {
    public static var UTC: TimeZone { TimeZone(abbreviation: "UTC")! }
    public static var IST: TimeZone { TimeZone(abbreviation: "IST")! }
    public static func mockAny() -> TimeZone { .IST }
}

extension Calendar {
    public static var gregorian: Calendar {
        return Calendar(identifier: .gregorian)
    }
}

extension TimeInterval {
    public static let distantFuture = TimeInterval(integerLiteral: .max)
    
    public static func mockRandomInThePast() -> TimeInterval {
        return random(in: 0..<Date().timeIntervalSinceReferenceDate)
    }
}

extension URLResponse {
    public static func mockAny() -> HTTPURLResponse {
        return .mockResponseWith(statusCode: 200)
    }
    
    public static func mockResponseWith(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: .mockAny(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    public static func mockWith(
        statusCode: Int = 200,
        mimeType: String? = "application/json"
    ) -> HTTPURLResponse {
        let headers: [String: String] = (mimeType == nil) ? [:] : ["Content-Type": "\(mimeType!)"]
        return HTTPURLResponse(
            url: .mockAny(),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headers
        )!
    }
}

extension Data: AnyMockable, RandomMockable {
    public static func mockAny() -> Data {
        return .mock(ofSize: 256)
    }
    
    public static func mockRepeating(byte: UInt8, times count: Int) -> Data {
        return Data(repeating: byte, count: count)
    }
    
    public static func mock<Size>(ofSize size: Size) -> Data where Size: BinaryInteger {
        return mockRepeating(byte: .mockRandom(), times: Int(size))
    }
    
    public static func mockRandom<Size>(ofSize size: Size) -> Data where Size: BinaryInteger {
        let count = Int(size)
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        defer { bytes.deallocate() }
        let status = SecRandomCopyBytes(kSecRandomDefault, count, bytes)
        
        guard status == errSecSuccess else {
            fatalError("Failed to generate random data")
        }
        
        return Data(bytes: bytes, count: count)
    }
    
    public static func mockRandom() -> Data {
        return mockRandom(ofSize: Int.mockRandom(min: 16, max: 512))
    }
}

extension URLRequest: AnyMockable {
    public static func mockAny() -> URLRequest {
        return .mockWith()
    }
    
    public static func mockWith(httpMethod: String) -> URLRequest {
        var request = URLRequest(url: .mockAny())
        request.httpMethod = httpMethod
        return request
    }
    
    public static func mockWith(
        url: String,
        queryParams: [URLQueryItem]? = nil,
        httpMethod: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> URLRequest {
        let url: URL = .mockWith(url: url, queryParams: queryParams)
        return mockWith(url: url, httpMethod: httpMethod, headers: headers, body: body)
    }
    
    public static func mockWith(
        url: URL = .mockAny(),
        httpMethod: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
