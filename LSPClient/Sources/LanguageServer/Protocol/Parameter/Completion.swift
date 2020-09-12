//
//  Completion.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Completion Request (textDocument/completion)

struct CompletionParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
    let context: CompletionContext?
}

enum CompletionTriggerKind: Int, Codable {
    case invoked = 1
    case triggerCharacter = 2
    case triggerForIncompleteCompletions = 3
}

struct CompletionContext: Codable {
    let triggerKind: CompletionTriggerKind
    let triggerCharacter: String?
}

struct CompletionList: ResultType {
    let isIncomplete: Bool
    let items: [CompletionItem]

    private enum CodingKeys: String, CodingKey {
        case isIncomplete
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.isIncomplete) {
            self.isIncomplete = try container.decode(Bool.self, forKey: .isIncomplete)
            self.items = try container.decode([CompletionItem].self, forKey: .items)
        } else {
            self.isIncomplete = false
            self.items = try decoder.singleValueContainer().decode([CompletionItem].self)
        }
    }
}

enum InsertTextFormat: Int, Codable {
    case plainText = 1
    case snippet = 2
}

enum CompletionItemTag: Int, Codable {
    case deprecated = 1
}

struct CompletionItem: RequestParamsType, ResultType {
    let label: String
    let kind: CompletionItemKind?
    let tags: [CompletionItemTag]?
    let detail: String?
    let documentation: Documentation?
    let deprecated: Bool?
    let preselect: Bool?
    let sortText: String?
    let filterText: String?
    let insertText: String?
    let insertTextFormat: InsertTextFormat?
    let textEdit: TextEdit?
    let additionalTextEdits: [TextEdit]?
    let commitCharacters: [String]?
    let command: Command?
    let data: AnyValue?
}

extension CompletionItem {
    enum Documentation: Codable {
        case string(String)
        case markup(MarkupContent)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                self = .string(value)
            } else {
                self = .markup(try container.decode(MarkupContent.self))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .markup(let value):
                try container.encode(value)
            }
        }
    }
}

enum CompletionItemKind: Int, Codable {
    case text = 1
    case method = 2
    case function = 3
    case constructor = 4
    case field = 5
    case variable = 6
    case `class` = 7
    case interface = 8
    case module = 9
    case property = 10
    case unit = 11
    case value = 12
    case `enum` = 13
    case keyword = 14
    case snippet = 15
    case color = 16
    case file = 17
    case reference = 18
    case folder = 19
    case enumMember = 20
    case constant = 21
    case `struct` = 22
    case event = 23
    case `operator` = 24
    case typeParameter = 25
}
