//
//  CodeAction.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Code Action Request (textDocument/codeAction)

struct CodeActionParams: RequestParamsType {
	let textDocument: TextDocumentIdentifier
	let range: Range
	let context: CodeActionContext
}

enum CodeActionKind: String, Codable {
	case empty = ""
	case quickFix = "quickfix"
	case refactor = "refactor"
	case refactorExtract = "refactor.extract"
	case refactorInline = "refactor.inline"
	case refactorRewrite = "refactor.rewrite"
	case source = "source"
	case sourceOrganizeImports = "source.organizeImports"
}

struct CodeActionContext: Codable {
	let diagnostics: [Diagnostic]
	let only: [CodeActionKind]?
}

enum CodeActionResult: ResultType {
	case command([Command])
	case codeAction([CodeAction])

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		if let value = try? container.decode([Command].self) {
			self = .command(value)
		} else {
			self = .codeAction(try container.decode([CodeAction].self))
		}
	}

	func encode(to encoder: Encoder) throws {
		fatalError("TODO")
	}
}

struct CodeAction: Codable {
	let title: String
	let kind: CodeActionKind?
	let diagnostics: [Diagnostic]?
	let isPreferred: Bool?
	let edit: WorkspaceEdit?
	let command: Command?
}
