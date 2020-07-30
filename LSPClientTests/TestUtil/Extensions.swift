//
//  Extensions.swift
//  LSPClientTests
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation
@testable import LSPClient

extension AnyValue {

	var isEmpty: Bool {
		if let value = value as? [String: Any?] {
			return value.isEmpty
		} else if let value = value as? [Any?] {
			return value.isEmpty
		} else {
			fatalError()
		}
	}

	var isVoid: Bool {
		return value is ()
	}

	var count: Int {
		if let value = value as? [String: Any?] {
			return value.count
		} else if let value = value as? [Any?] {
			return value.count
		} else {
			fatalError()
		}
	}

	subscript(_ key: String) -> AnyValue {
		guard let value = value as? [String: Any?] else {
			fatalError()
		}
		return AnyValue(value[key]!)
	}

	subscript(_ index: Int) -> AnyValue {
		guard let value = value as? [Any?] else {
			fatalError()
		}
		return AnyValue(value[index])
	}

}

extension AnyValue: Equatable {

	public static func == (lhs: AnyValue, rhs: AnyValue) -> Bool {
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
		case let (lhs as [String : AnyValue], rhs as [String : AnyValue]):
			return lhs == rhs
		default:
			return false
		}
	}

}

extension AnyValue: CustomStringConvertible {

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

extension AnyValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, ExpressibleByStringLiteral {

	public init(integerLiteral value: Int) {
		self = AnyValue(value)
	}

	public init(floatLiteral value: Float) {
		self = AnyValue(value)
	}

	public init(booleanLiteral value: Bool) {
		self = AnyValue(value)
	}

	public init(stringLiteral value: String) {
		self = AnyValue(value)
	}

}

