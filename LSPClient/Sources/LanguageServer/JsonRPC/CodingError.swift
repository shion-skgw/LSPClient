//
//  CodingError.swift
//  LSPClient
//
//  Created by Shion on 2020/06/18.
//  Copyright © 2020 Shion. All rights reserved.
//

enum MessageDecodingError: Error {
	case unsupportedMethod(RequestID?, String)
	case unknownRequestID
}

extension DecodingError {

	static func dataCorruptedError(_ path: [CodingKey], _ description: String) -> DecodingError {
		return .dataCorrupted(.init(codingPath: path, debugDescription: description))
	}

	static func typeMismatchError(_ type: Any.Type, _ path: [CodingKey], _ description: String) -> DecodingError {
		return .typeMismatch(type, .init(codingPath: path, debugDescription: description))
	}

}

extension EncodingError {

	static func invalidValueError(_ value: Any, _ path: [CodingKey], _ description: String) -> EncodingError {
		return .invalidValue(value, .init(codingPath: path, debugDescription: description))
	}

}
