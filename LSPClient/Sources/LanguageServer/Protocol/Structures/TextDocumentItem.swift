//
//  TextDocumentItem.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

struct TextDocumentItem: Codable {
    let uri: DocumentUri
    let languageId: LanguageID
    let version: Int
    let text: String
}

enum LanguageID: String, Codable {
    case ABAP = "abap"
}
// TODO
