//
//  TextDocumentPositionParams.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol TextDocumentPositionParamsType {
	var textDocument: TextDocumentIdentifier { get }
	var position: Position { get }
}

struct TextDocumentPositionParams: TextDocumentPositionParamsType, Codable {
	let textDocument: TextDocumentIdentifier
	let position: Position
}
