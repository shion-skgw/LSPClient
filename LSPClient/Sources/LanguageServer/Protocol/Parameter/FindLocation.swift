//
//  FindLocation.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Goto Declaration Request (textDocument/declaration)

struct DeclarationParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
}

struct FindLocationResult: ResultType {
    let locations: [Location]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Location.self) {
            self.locations = [value]
        } else {
            self.locations = try container.decode([Location].self)
        }
    }
}


// MARK: - Goto Definition Request (textDocument/definition)

struct DefinitionParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
}


// MARK: - Goto Type Definition Request (textDocument/typeDefinition)

struct TypeDefinitionParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
}


// MARK: - Goto Implementation Request (textDocument/implementation)

struct ImplementationParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
}


// MARK: - Find References Request (textDocument/references)

struct ReferenceParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
    let context: ReferenceContext
}

struct ReferenceContext: Codable {
    let includeDeclaration: Bool
}
