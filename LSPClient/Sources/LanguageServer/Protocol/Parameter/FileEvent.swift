//
//  FileEvent.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//


// MARK: - DidChangeWatchedFiles Notification (workspace/didChangeWatchedFiles)

struct DidChangeWatchedFilesParams: NotificationParamsType {
	let changes: [FileEvent]
}

struct FileEvent: Codable {
	let uri: DocumentUri
	let type: FileChangeType
}

enum FileChangeType: Int, Codable {
	case created = 1
	case changed = 2
	case deleted = 3
}


// MARK: - DidOpenTextDocument Notification (textDocument/didOpen)

struct DidOpenTextDocumentParams: NotificationParamsType {
	let textDocument: TextDocumentItem
}


// MARK: - DidChangeTextDocument Notification (textDocument/didChange)

struct DidChangeTextDocumentParams: NotificationParamsType {
	let textDocument: VersionedTextDocumentIdentifier
	let contentChanges: [TextDocumentContentChangeEvent]
}

enum TextDocumentContentChangeEvent: Codable {
	case full(String)
	case incremental(TextRange, Int, String)

	private enum CodingKeys: String, CodingKey {
		case range
		case rangeLength
		case text
	}

	init(from decoder: Decoder) throws {
		throw DecodingError.dataCorruptedError(decoder.codingPath, "Send only.")
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch self {
		case .full(let text):
			try container.encode(text, forKey: .text)
		case .incremental(let range, let rangeLength, let text):
			try container.encode(range, forKey: .range)
			try container.encode(rangeLength, forKey: .rangeLength)
			try container.encode(text, forKey: .text)
		}
	}
}


// MARK: - DidSaveTextDocument Notification (textDocument/didSave)

struct DidSaveTextDocumentParams: NotificationParamsType {
	let textDocument: TextDocumentIdentifier
	let text: String?
}


// MARK: - DidCloseTextDocument Notification (textDocument/didClose)

struct DidCloseTextDocumentParams: NotificationParamsType {
	let textDocument: TextDocumentIdentifier
}
