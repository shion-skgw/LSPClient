//
//  MarkupContent.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

struct MarkupContent: Codable {
    let kind: MarkupKind
    let value: String
}

enum MarkupKind: String, Codable {
    case plaintext = "plaintext"
    case markdown = "markdown"
}
