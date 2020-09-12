//
//  TextDocumentIdentifier.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol TextDocumentIdentifierType {
    var uri: DocumentUri { get }
}

struct TextDocumentIdentifier: TextDocumentIdentifierType, Codable {
    let uri: DocumentUri
}
