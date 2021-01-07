//
//  Syntax.swift
//  LSPClient
//
//  Created by Shion on 2020/09/19.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class SyntaxLoader {

    private static let defaultWordBoundary = "\\b"
    private static let syntaxMap: [String: String] = [
        "swift": "Swift",
    ]

    private static var syntaxes: [SyntaxDefinition] = []

    private init() {}

    static func tokens(fileExtension: String, codeStyle: CodeStyle) -> [Token] {
        let definitions = loadDefinitions(fileExtension)
        var tokens = [Token]()
        for definition in definitions.definitions {
            let ignoreCase = definition.ignoreCase == true
            let multipleLines = definition.multipleLines == true
            let color = textColor(definition.type, codeStyle)

            if definition.regex == true {
                definition.strings.forEach() {
                    tokens.append(Token(pattern: $0, isIgnoreCase: ignoreCase, isMultipleLines: multipleLines, textColor: color))
                }

            } else if let allowTokenPattern = definitions.allowTokenPattern {
                let before = "(?<=[^\(allowTokenPattern)]|^)"
                let after = "(?=[^\(allowTokenPattern)]|$)"
                let pattern = "\(before)(\(definition.strings.joined(separator: "|")))\(after)"
                tokens.append(Token(pattern: pattern, isIgnoreCase: ignoreCase, isMultipleLines: multipleLines, textColor: color))

            } else {
                let pattern = "\\b(\(definition.strings.joined(separator: "|")))\\b"
                tokens.append(Token(pattern: pattern, isIgnoreCase: ignoreCase, isMultipleLines: multipleLines, textColor: color))
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

    private static func textColor(_ type: SyntaxType, _ codeStyle: CodeStyle) -> UIColor {
        switch type {
        case .keyword: return codeStyle.fontColor.keyword.uiColor
        case .function: return codeStyle.fontColor.function.uiColor
        case .number: return codeStyle.fontColor.number.uiColor
        case .string: return codeStyle.fontColor.string.uiColor
        case .comment: return codeStyle.fontColor.comment.uiColor
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
    }

}
