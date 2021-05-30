//
//  SignatureHelp.swift
//  LSPClient
//
//  Created by Shion on 2021/05/24.
//  Copyright © 2021 Shion. All rights reserved.
//

// MARK: - Signature Help Request (textDocument/signatureHelp)

struct SignatureHelpParams: RequestParamsType, TextDocumentPositionParamsType {
    let textDocument: TextDocumentIdentifier
    let position: TextPosition
    let context: SignatureHelpContext?
}

enum SignatureHelpTriggerKind: Int, Codable {
    case invoked = 1
    case triggerCharacter = 2
    case contentChange = 3
}

struct SignatureHelpContext: Codable {
    let triggerKind: SignatureHelpTriggerKind
    let triggerCharacter: String?
    let isRetrigger: Bool
    let activeSignatureHelp: SignatureHelp?
}

struct SignatureHelp: ResultType {
    let signatures: [SignatureInformation]
    let activeSignature: Int?
    let activeParameter: Int?
}

struct SignatureInformation: Codable {
    let label: String
    let documentation: SignatureHelp.Documentation?
    let parameters: [ParameterInformation]?
}

struct ParameterInformation: Codable {
    let label: Label
    let documentation: SignatureHelp.Documentation?
}

extension SignatureHelp {
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

extension ParameterInformation {
    enum Label: Codable {
        case string(String)
        case number(Int, Int)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                self = .string(value)
            } else {
                let value = try container.decode([Int].self)
                if value.count != 2 {
                    throw DecodingError.dataCorruptedError(container.codingPath, "TODO")
                }
                self = .number(value[0], value[1])
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .number(let start, let end):
                try container.encode([start, end])
            }
        }
    }
}
