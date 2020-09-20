//
//  Syntax.swift
//  LSPClient
//
//  Created by Shion on 2020/09/19.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

final class SyntaxLoader {

    private static let defaultWordBoundary = "\\b"
    private static let syntaxMap: [String: String] = [
        "swift": "Swift",
    ]

    private static var syntaxes: [SyntaxDefinition] = []

    private init() {}

    static func tokens(fileExtension: String) -> [Token] {
        let definitions = loadDefinitions(fileExtension)
        var tokens = [Token]()
        definitions.definitions.forEach() {
            let type = $0.type.tokenType
            let isIgnoreCase = $0.ignoreCase == true
            let isMultipleLines = $0.multipleLines == true

            if $0.regex == true {
                tokens.append(Token(type: type, pattern: $0.strings[0], isIgnoreCase: isIgnoreCase, isMultipleLines: isMultipleLines))

            } else if let allowTokenPattern = definitions.allowTokenPattern {
                let before = "(?<=[^\(allowTokenPattern)]|^)"
                let after = "(?=[^\(allowTokenPattern)]|$)"
                let pattern = "\(before)(\($0.strings.joined(separator: "|")))\(after)"
                tokens.append(Token(type: type, pattern: pattern, isIgnoreCase: isIgnoreCase, isMultipleLines: isMultipleLines))

            } else {
                let pattern = "\\b(\($0.strings.joined(separator: "|")))\\b"
                tokens.append(Token(type: type, pattern: pattern, isIgnoreCase: isIgnoreCase, isMultipleLines: isMultipleLines))
            }
        }
        return tokens
    }

    private static func loadDefinitions(_ fileExtension: String) -> SyntaxDefinition {
        if let definitions = syntaxes.filter({ $0.extensions.contains(fileExtension) }).first {
            return definitions
        }

        guard let path = Bundle.main.path(forResource: syntaxMap[fileExtension], ofType: "plist") else {
            fatalError()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let definitions = try PropertyListDecoder().decode(SyntaxDefinition.self, from: data)
            syntaxes.append(definitions)
            return definitions
        } catch {
            fatalError()
        }
    }

}


extension SyntaxLoader {

    struct SyntaxDefinition: Decodable {
        let extensions: [String]
        let allowTokenPattern: String?
        let definitions: [Definition]
    }

    struct Definition: Decodable {
        let description: String?
        let `type`: SyntaxType
        let strings: [String]
        let regex: Bool?
        let ignoreCase: Bool?
        let multipleLines: Bool?
    }

    enum SyntaxType: String, Decodable {
        case keyword
        case function
        case number
        case string
        case comment

        var tokenType: Token.TokenType {
            switch self {
            case .keyword : return .keyword
            case .function: return .function
            case .number  : return .number
            case .string  : return .string
            case .comment : return .comment
            }
        }
    }

}
