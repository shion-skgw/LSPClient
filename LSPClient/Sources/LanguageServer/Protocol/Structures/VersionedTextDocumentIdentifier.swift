//
//  VersionedTextDocumentIdentifier.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

struct VersionedTextDocumentIdentifier: TextDocumentIdentifierType, Codable {
	let uri: DocumentUri
	let version: RequiredValue<Int>
}
