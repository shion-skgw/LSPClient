//
//  AnyValue.swift
//  LSPClient
//
//  Created by Shion on 2020/06/08.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

struct AnyValue {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

extension AnyValue: ResultType {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(())
        } else if let value = try? container.decode(Bool.self) {
            self.init(value)
        } else if let value = try? container.decode(Int.self) {
            self.init(value)
        } else if let value = try? container.decode(Double.self) {
            self.init(value)
        } else if let value = try? container.decode(String.self) {
            self.init(value)
        } else if let value = try? container.decode([AnyValue].self) {
            self.init(value.map({ $0.value }))
        } else if let value = try? container.decode([String: AnyValue].self) {
            self.init(value.mapValues({ $0.value }))
        } else {
            throw DecodingError.typeMismatchError(AnyValue.self, container.codingPath, "TODO")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self.value {
        case is Void:
            try container.encodeNil()
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(Decimal(string: String(value))!)
        case let value as String:
            try container.encode(value)
        case let value as [Any?]:
            try container.encode(value.map({ AnyValue($0) }))
        case let value as [String: Any?]:
            try container.encode(value.mapValues({ AnyValue($0) }))
        default:
            throw EncodingError.invalidValueError(value, container.codingPath, "TODO")
        }
    }
}

extension AnyValue: Equatable {
    static func == (lhs: AnyValue, rhs: AnyValue) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [AnyValue], rhs as [AnyValue]):
            return lhs == rhs
        case let (lhs as [String: AnyValue], rhs as [String: AnyValue]):
            return lhs == rhs
        default:
            return false
        }
    }
}
