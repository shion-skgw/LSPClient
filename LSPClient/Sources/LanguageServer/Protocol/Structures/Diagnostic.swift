//
//  Diagnostic.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct Diagnostic: Codable {
	let range: TextRange
	let severity: DiagnosticSeverity?
	let code: DiagnosticCode?
	let source: String?
	let message: String
	let tags: [DiagnosticTag]?
	let relatedInformation: [DiagnosticRelatedInformation]?
}

enum DiagnosticCode: Codable {
	case number(Int)
	case string(String)

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		if let value = try? container.decode(Int.self) {
			self = .number(value)
		} else {
			self = .string(try container.decode(String.self))
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
		case .string(let value):
			try container.encode(value)
		case .number(let value):
			try container.encode(value)
		}
	}
}

enum DiagnosticSeverity: Int, Codable {
	case error = 1
	case warning = 2
	case information = 3
	case hint = 4
}

enum DiagnosticTag: Int, Codable {
	case unnecessary = 1
	case deprecated = 2
}

struct DiagnosticRelatedInformation: Codable {
	let location: Location
	let message: String
}
