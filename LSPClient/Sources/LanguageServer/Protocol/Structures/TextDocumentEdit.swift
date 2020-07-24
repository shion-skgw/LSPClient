//
//  TextDocumentEdit.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct TextDocumentEdit: Codable {
	let textDocument: VersionedTextDocumentIdentifier
	let edits: [TextEdit]
}
