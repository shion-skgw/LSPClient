//
//  CodeFormat.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Document Formatting Request (textDocument/formatting)

struct DocumentFormattingParams: RequestParamsType {
	let textDocument: TextDocumentIdentifier
	let options: FormattingOptions
}

struct FormattingOptions: Codable {
	let tabSize: Int
	let insertSpaces: Bool
	let trimTrailingWhitespace: Bool?
	let insertFinalNewline: Bool?
	let trimFinalNewlines: Bool?
}


// MARK: - Document Range Formatting Request (textDocument/rangeFormatting)

struct DocumentRangeFormattingParams: RequestParamsType {
	let textDocument: TextDocumentIdentifier
	let range: TextRange
	let options: FormattingOptions
}
