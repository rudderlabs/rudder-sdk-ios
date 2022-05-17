//
//  RSAnyEncodable.swift
//  RudderStack
//
//  Created by Pallab Maiti on 17/11/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

#if canImport(Foundation)
import Foundation
#endif

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

@frozen public struct RSAnyEncodable: Encodable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

@usableFromInline
protocol _RSAnyEncodable {
    var value: Any { get }
    init<T>(_ value: T?)
}

extension RSAnyEncodable: _RSAnyEncodable {}

// MARK: - Encodable
extension _RSAnyEncodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        #if canImport(Foundation)
        case let number as NSNumber:
            try encode(nsnumber: number, into: &container)
        case is NSNull:
            try container.encodeNil()
        #endif
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        #if canImport(Foundation)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        #endif
        case let array as [Any?]:
            try container.encode(array.map { RSAnyEncodable($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { RSAnyEncodable($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }

    #if canImport(Foundation)
    private func encode(nsnumber: NSNumber, into container: inout SingleValueEncodingContainer) throws {
        switch Character(Unicode.Scalar(UInt8(nsnumber.objCType.pointee))) {
        case "c", "C":
            try container.encode(nsnumber.boolValue)
        case "s":
            try container.encode(nsnumber.int8Value)
        case "i":
            try container.encode(nsnumber.int16Value)
        case "l":
            try container.encode(nsnumber.int32Value)
        case "q":
            try container.encode(nsnumber.int64Value)
        case "S":
            try container.encode(nsnumber.uint8Value)
        case "I":
            try container.encode(nsnumber.uint16Value)
        case "L":
            try container.encode(nsnumber.uint32Value)
        case "Q":
            try container.encode(nsnumber.uint64Value)
        case "f":
            try container.encode(nsnumber.floatValue)
        case "d":
            try container.encode(nsnumber.doubleValue)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "NSNumber cannot be encoded because its type is not handled")
            throw EncodingError.invalidValue(nsnumber, context)
        }
    }
    #endif
}

extension RSAnyEncodable: Equatable {
    public static func == (lhs: RSAnyEncodable, rhs: RSAnyEncodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: RSAnyEncodable], rhs as [String: RSAnyEncodable]):
            return lhs == rhs
        case let (lhs as [RSAnyEncodable], rhs as [RSAnyEncodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension RSAnyEncodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

extension RSAnyEncodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyEncodable(\(value.debugDescription))"
        default:
            return "AnyEncodable(\(description))"
        }
    }
}

extension RSAnyEncodable: ExpressibleByNilLiteral {}
extension RSAnyEncodable: ExpressibleByBooleanLiteral {}
extension RSAnyEncodable: ExpressibleByIntegerLiteral {}
extension RSAnyEncodable: ExpressibleByFloatLiteral {}
extension RSAnyEncodable: ExpressibleByStringLiteral {}
extension RSAnyEncodable: ExpressibleByStringInterpolation {}
extension RSAnyEncodable: ExpressibleByArrayLiteral {}
extension RSAnyEncodable: ExpressibleByDictionaryLiteral {}

extension _RSAnyEncodable {
    public init(nilLiteral _: ()) {
        self.init(nil as Any?)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        self.init([AnyHashable: Any](elements, uniquingKeysWith: { first, _ in first }))
    }
}

extension RSAnyEncodable: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch value {
        case let value as Bool:
            hasher.combine(value)
        case let value as Int:
            hasher.combine(value)
        case let value as Int8:
            hasher.combine(value)
        case let value as Int16:
            hasher.combine(value)
        case let value as Int32:
            hasher.combine(value)
        case let value as Int64:
            hasher.combine(value)
        case let value as UInt:
            hasher.combine(value)
        case let value as UInt8:
            hasher.combine(value)
        case let value as UInt16:
            hasher.combine(value)
        case let value as UInt32:
            hasher.combine(value)
        case let value as UInt64:
            hasher.combine(value)
        case let value as Float:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as String:
            hasher.combine(value)
        case let value as [String: RSAnyEncodable]:
            hasher.combine(value)
        case let value as [RSAnyEncodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}
