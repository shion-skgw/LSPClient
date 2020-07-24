//
//  Hover.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Hover Request (textDocument/hover)

struct HoverParams: RequestParamsType, TextDocumentPositionParamsType {
	let textDocument: TextDocumentIdentifier
	let position: Position
}

struct Hover: ResultType {
	let contents: MarkupContent
	let range: Range?

	private enum CodingKeys: String, CodingKey {
		case contents
		case range
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		if let value = try? container.decode(MarkedString.self, forKey: .contents) {
			self.contents = MarkupContent(kind: .plaintext, value: value.value)
			self.range = nil
		} else if let value = try? container.decode([MarkedString].self, forKey: .contents) {
			self.contents = MarkupContent(kind: .plaintext, value: value.first?.value ?? "")
			self.range = nil
		} else {
			self.contents = try container.decode(MarkupContent.self, forKey: .contents)
			self.range = try container.decode(Range.self, forKey: .range)
		}
	}
}

struct MarkedString: Codable {
	let language: String?
	let value: String

	private enum CodingKeys: String, CodingKey {
		case language
		case value
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		if container.contains(.language) {
			self.language = try container.decode(String.self, forKey: .language)
			self.value = try container.decode(String.self, forKey: .value)
		} else {
			self.language = nil
			self.value = try decoder.singleValueContainer().decode(String.self)
		}
	}
}
