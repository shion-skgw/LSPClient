//
//  SyntaxManager.swift
//  LSPClient
//
//  Created by Shion on 2021/04/29.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

final class SyntaxManager {

    private static var storage: NSMutableDictionary = [:]
    private static let languageTable: [String: String] = [
        "swift": "Swift",
        "py": "Python",
    ]

    let syntaxes: [SyntaxRegex]
    let commentOpenSymbol: [String]
    let multipleLineSymbol: [String]
    let isBracketIndent: Bool
    let invalidRangeRegex: NSRegularExpression?
    let indentTriggerRegex: NSRegularExpression!
    let deindentTriggerRegex: NSRegularExpression!

    static func load(fileExtension: String) -> SyntaxManager? {
        guard let language = languageTable[fileExtension] else {
            return nil
        }

        if let instance = storage[language] as? SyntaxManager {
            return instance
        }

        let definition = loadDefinition(language)
        let instance = self.init(definition)
        storage[language] = instance
        return instance
    }

    private static func loadDefinition(_ language: String) -> CommonDefinition {
        guard let path = Bundle.main.path(forResource: language, ofType: "plist") else {
            fatalError()
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let definition = try PropertyListDecoder().decode(CommonDefinition.self, from: data)
            assert(checkDefinition(definition))
            return definition
        } catch {
            fatalError()
        }
    }

    private init(_ definition: CommonDefinition) {
        var syntaxes: [SyntaxRegex] = []
        var commentOpenSymbol: [String] = []
        var multipleLineSymbol: Set<String> = []
        var invalidLinePattern: [String] = []

        for group in definition.syntaxGroups {
            if group.type == .string || group.type == .comment {
                invalidLinePattern.append(contentsOf: group.enclosures)

                if group.type == .comment {
                    commentOpenSymbol.append(contentsOf: group.rawOpens)
                }

                if group.isMultiple {
                    group.rawOpens.forEach({ multipleLineSymbol.insert($0) })
                    group.rawCloses.forEach({ multipleLineSymbol.insert($0) })
                }

            } else if group.isRegex {
                for syntax in group.syntaxes {
                    let options: NSRegularExpression.Options = group.isIgnoreCase ? .caseInsensitive : []
                    let regex = try! NSRegularExpression(pattern: syntax.string!, options: options)
                    syntaxes.append(SyntaxRegex(type: group.type, regex: regex))
                }

            } else {
                let prefix = definition.wordBoundaryPrefix
                let suffix = definition.wordBoundarySuffix
                let pattern = "\(prefix)(\(group.strings.joined(separator: "|")))\(suffix)"
                let options: NSRegularExpression.Options = group.isIgnoreCase ? .caseInsensitive : []
                let regex = try! NSRegularExpression(pattern: pattern, options: options)
                syntaxes.append(SyntaxRegex(type: group.type, regex: regex))
            }
        }

        self.syntaxes = syntaxes
        self.commentOpenSymbol = commentOpenSymbol
        self.multipleLineSymbol = Array(multipleLineSymbol)
        self.isBracketIndent = !definition.indentTrigger.isEmpty && !definition.deindentTrigger.isEmpty

        if !invalidLinePattern.isEmpty {
            let pattern = "(\(invalidLinePattern.joined(separator: "|")))"
            let options: NSRegularExpression.Options = [.dotMatchesLineSeparators, .anchorsMatchLines]
            self.invalidRangeRegex = try! NSRegularExpression(pattern: pattern, options: options)
        } else {
            self.invalidRangeRegex = nil
        }

        if self.isBracketIndent {
            self.indentTriggerRegex = try! NSRegularExpression(pattern: "(\(definition.escapedIndentTriggers.joined(separator: "|")))")
            self.deindentTriggerRegex = try! NSRegularExpression(pattern: "(\(definition.escapedDeindentTriggers.joined(separator: "|")))")
        } else {
            self.indentTriggerRegex = nil
            self.deindentTriggerRegex = nil
        }
    }

    func highlightRange(text: String, range: NSRange) -> NSRange {
        let fullRange = text.range
        let lineRange = (text as NSString).lineRange(for: range)
        let tampRange = NSMakeRange(range.location - 1, range.length + 1)

        if let range = Range(NSIntersectionRange(tampRange, fullRange), in: text) {
            let text = text[range]
            return multipleLineSymbol.contains(where: { text.contains($0) }) ? fullRange : lineRange

        } else {
            return lineRange
        }
    }

    func highlight(text: String, range: NSRange) -> [SyntaxRange] {
        var highlight: [SyntaxRange] = []

        invalidRangeRegex?.enumerateMatches(in: text, range: text.range) {
            result, _, _ in
            guard let nsRange = result?.range, let range = Range(nsRange, in: text) else {
                return
            }
            let syntaxType: SyntaxType = commentOpenSymbol.contains(where: { text[range].hasPrefix($0) }) ? .comment : .string
            highlight.append(SyntaxRange(type: syntaxType, range: nsRange))
        }

        for syntax in syntaxes {
            syntax.regex.enumerateMatches(in: text, range: range) {
                result, _, _ in
                guard let nsRange = result?.range else {
                    return
                }
                if !highlight.contains(where: { NSLocationInRange(nsRange.location, $0.range) }) {
                    highlight.append(SyntaxRange(type: syntax.type, range: nsRange))
                }
            }
        }
        return highlight
    }

    func indentLevel(text: String, location: Int) -> Int {
        if !isBracketIndent {
            return 0
        }

        let range = NSMakeRange(.zero, location)

        let invalidRange = invalidRangeRegex?.matches(in: text, range: range).compactMap({ $0.range }) ?? []

        var level = 0
        indentTriggerRegex.matches(in: text, range: range).forEach() {
            result in
            level += invalidRange.contains(where: { NSLocationInRange(result.range.location, $0) }) ? 0 : 1
        }
        deindentTriggerRegex.matches(in: text, range: range).forEach() {
            result in
            level -= invalidRange.contains(where: { NSLocationInRange(result.range.location, $0) }) ? 0 : 1
        }
        return level >= .zero ? level : .zero
    }

}


extension SyntaxManager {

    struct SyntaxRegex {
        let type: SyntaxType
        let regex: NSRegularExpression
    }

    struct SyntaxRange {
        let type: SyntaxType
        let range: NSRange
    }

}

fileprivate struct CommonDefinition: Codable {
    let allowTokenPattern: String?
    let indentTrigger: [String]
    let deindentTrigger: [String]
    let syntaxGroups: [SyntaxGroupDefinition]

    var wordBoundaryPrefix: String {
        allowTokenPattern != nil ? "(?<=[^\(allowTokenPattern!)]|^)" : "\\b"
    }
    var wordBoundarySuffix: String {
        allowTokenPattern != nil ? "(?=[^\(allowTokenPattern!)]|$)" : "\\b"
    }
    var escapedIndentTriggers: [String] {
        indentTrigger.map({ NSRegularExpression.escapedPattern(for: $0) })
    }
    var escapedDeindentTriggers: [String] {
        deindentTrigger.map({ NSRegularExpression.escapedPattern(for: $0) })
    }
}

fileprivate struct SyntaxGroupDefinition: Codable {
    let description: String
    let type: SyntaxType
    let isRegex: Bool
    let isIgnoreCase: Bool
    let isMultiple: Bool
    let syntaxes: [SyntaxDefinition]

    var strings: [String] {
        isRegex ? syntaxes.compactMap({ $0.string }) : syntaxes.compactMap({ $0.escapedString })
    }
    var enclosures: [String] {
        let join = isMultiple ? ".*?" : "[^\n]*?"
        return syntaxes.compactMap({ $0.open != nil ? "\($0.escapedOpen!)\(join)\($0.escapedClose ?? "$")" : nil })
    }
    var rawOpens: [String] {
        syntaxes.compactMap({ $0.open })
    }
    var rawCloses: [String] {
        syntaxes.compactMap({ $0.close })
    }
}

fileprivate struct SyntaxDefinition: Codable {
    let string: String?
    let open: String?
    let close: String?

    var escapedString: String? {
        string != nil ? NSRegularExpression.escapedPattern(for: string!) : nil
    }
    var escapedOpen: String? {
        open != nil ? NSRegularExpression.escapedPattern(for: open!) : nil
    }
    var escapedClose: String? {
        close != nil ? NSRegularExpression.escapedPattern(for: close!) : nil
    }
}

fileprivate func checkDefinition(_ definition: CommonDefinition) -> Bool {
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

