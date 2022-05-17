//
//  RSAnyCodable.swift
//  RudderStack
//
//  Created by Pallab Maiti on 16/11/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

// swiftlint:disable cyclomatic_complexity

@frozen public struct RSAnyCodable: Codable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

extension RSAnyCodable: _RSAnyEncodable, _RSAnyDecodable {}

extension RSAnyCodable: Equatable {
    public static func == (lhs: RSAnyCodable, rhs: RSAnyCodable) -> Bool {
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
        case let (lhs as [String: RSAnyCodable], rhs as [String: RSAnyCodable]):
            return lhs == rhs
        case let (lhs as [RSAnyCodable], rhs as [RSAnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension RSAnyCodable: CustomStringConvertible {
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

extension RSAnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyCodable(\(value.debugDescription))"
        default:
            return "AnyCodable(\(description))"
        }
    }
}

extension RSAnyCodable: ExpressibleByNilLiteral {}
extension RSAnyCodable: ExpressibleByBooleanLiteral {}
extension RSAnyCodable: ExpressibleByIntegerLiteral {}
extension RSAnyCodable: ExpressibleByFloatLiteral {}
extension RSAnyCodable: ExpressibleByStringLiteral {}
extension RSAnyCodable: ExpressibleByArrayLiteral {}
extension RSAnyCodable: ExpressibleByDictionaryLiteral {}

extension RSAnyCodable: Hashable {
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
        case let value as [String: RSAnyCodable]:
            hasher.combine(value)
        case let value as [RSAnyCodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}
