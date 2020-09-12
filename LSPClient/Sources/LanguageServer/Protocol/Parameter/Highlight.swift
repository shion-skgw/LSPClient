//
//  Highlight.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Document Highlights Request (textDocument/documentHighlight)

struct DocumentHighlightParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
}

struct DocumentHighlight: ResultType {
    let range: TextRange
    let kind: DocumentHighlightKind?
}

enum DocumentHighlightKind: Int, Codable {
    case text = 1
    case read = 2
    case write = 3
}
