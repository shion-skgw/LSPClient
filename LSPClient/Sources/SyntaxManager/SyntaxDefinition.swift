//
//  SyntaxDefinition.swift
//  LSPClient
//
//  Created by Shion on 2021/05/27.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

struct CommonDefinition: Codable {
    let allowTokenPattern: String?
    let indentTrigger: [String]
    let deindentTrigger: [String]
    let syntaxGroups: [SyntaxGroupDefinition]

    var wordBoundaryPrefix: String {
        allowTokenPattern == nil ? "\\b" : "(?<=[^\(allowTokenPattern!)]|^)"
    }
    var wordBoundarySuffix: String {
        allowTokenPattern == nil ? "\\b" : "(?=[^\(allowTokenPattern!)]|$)"
    }
    var symbolicCharacter: String {
        // Exclude allowed characters from ASCII characters
        let asciiCodes = NSMutableString(string: [" "..."~", "\t", "\n"].joined())
        let allowToken = try! NSRegularExpression(pattern: "[\(allowTokenPattern ?? "\\w")]")
        allowToken.replaceMatches(in: asciiCodes, range: NSMakeRange(.zero, asciiCodes.length), withTemplate: "")
        return asciiCodes as String
    }
    var escapedIndentTrigger: [String] {
        indentTrigger.map({ NSRegularExpression.escapedPattern(for: $0) })
    }
    var escapedDeindentTrigger: [String] {
        deindentTrigger.map({ NSRegularExpression.escapedPattern(for: $0) })
    }
}

extension CommonDefinition {

    struct SyntaxGroupDefinition: Codable {
        let description: String
        let type: SyntaxType
        let isRegex: Bool
        let isIgnoreCase: Bool
        let isMultiple: Bool
        let syntaxes: [SyntaxDefinition]
    }

    struct SyntaxDefinition: Codable {
        let string: String?
        let open: String?
        let close: String?

        var escapedString: String? {
            string == nil ? nil : NSRegularExpression.escapedPattern(for: string!)
        }
        var escapedOpen: String? {
            open == nil ? nil : NSRegularExpression.escapedPattern(for: open!)
        }
        var escapedClose: String? {
            close == nil ? nil : NSRegularExpression.escapedPattern(for: close!)
        }
    }

}

private func ...(left: String, right: String) -> String {
    guard let start = left.unicodeScalars.first?.value, let end = right.unicodeScalars.last?.value, start < end else {
        fatalError()
    }
    return (start...end).map({ String(UnicodeScalar($0)!) }).joined()
}

func checkDefinition(_ definition: CommonDefinition) -> Bool {
    var result = true
    for group in definition.syntaxGroups {
        if group.syntaxes.isEmpty {
            print("Empty syntaxes in string \(group.type.rawValue).")
            result = false
        }
        if group.type == .string || group.type == .comment {
            if group.isRegex {
                print("\(group.type.rawValue) do not support regex.")
                result = false
            }
            if group.isIgnoreCase {
                print("\(group.type.rawValue) do not support ignore case.")
                result = false
            }
            if group.syntaxes.contains(where: { $0.string != nil }) {
                print("\(group.type.rawValue) do not support string.")
                result = false
            }
            if group.syntaxes.contains(where: { $0.open == nil }) {
                print("open is required for \(group.type.rawValue).")
                result = false
            }
            if group.isMultiple && group.syntaxes.contains(where: { $0.close == nil }) {
                print("close is required for multi-line \(group.type.rawValue).")
                result = false
            }
        } else {
            if group.isMultiple {
                print("\(group.type.rawValue) do not support multi-line.")
                result = false
            }
            if group.syntaxes.contains(where: { $0.string == nil }) {
                print("string is required for \(group.type.rawValue).")
                result = false
            }
            if group.syntaxes.contains(where: { $0.open != nil }) {
                print("\(group.type.rawValue) do not support open.")
                result = false
            }
            if group.syntaxes.contains(where: { $0.close != nil }) {
                print("\(group.type.rawValue) do not support close.")
                result = false
            }
        }
    }
    return result
}
