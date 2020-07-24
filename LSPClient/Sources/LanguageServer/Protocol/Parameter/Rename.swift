//
//  Rename.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Rename Request (textDocument/rename)

struct RenameParams: RequestParamsType, TextDocumentPositionParamsType {
	let textDocument: TextDocumentIdentifier
	let position: Position
	let newName: String
}
