//
//  SyntaxManager.swift
//  LSPClient
//
//  Created by Shion on 2021/04/29.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

final class SyntaxManager {

    private struct SyntaxRegex: Hashable {
        let type: SyntaxType
        let regex: NSRegularExpression
    }

    /// Definition file correspondence table
    private static let languageTable: [String: String] = [
        "swift" : "Swift",
        "py"    : "Python",
    ]

    /// Store the generated manager
    private static var storage: NSMutableDictionary = [:]

    /// Comment out string
    let commentOut: String?

    /// Syntax type and regex
    private let syntaxes: Set<SyntaxRegex>
    /// Comment start string
    private let commentOpen: Set<String>
    /// Multi-line comments and strings
    private let multilineSyntax: Set<String>
    /// Characters not allowed as word
    private let symbolicCharacter: CharacterSet
    /// Word boundary range regex
    private let wordRange: NSRegularExpression
    /// Comments and string ranges regex
    private let invalidRange: NSRegularExpression
    /// Indent trigger regex
    private let indentTrigger: NSRegularExpression?
    /// Deindent trigger regex
    private let deindentTrigger: NSRegularExpression?

    static func load(fileExtension: String) -> SyntaxManager? {
        guard let language = languageTable[fileExtension] else {
            return nil
        }

        if let instance = storage[language] as? SyntaxManager {
            return instance

        } else {
            let definition = loadDefinition(language)
            let instance = self.init(definition)
            storage[language] = instance
            return instance
        }
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
        // Initialize syntaxes
        let syntaxes = definition.syntaxGroups.filter({ $0.type != .comment && $0.type != .string }).flatMap() {
            group -> [SyntaxRegex] in
            if group.isRegex {
                return group.syntaxes.compactMap() {
                    guard let string = $0.string else {
                        return nil
                    }
                    let regex = try! NSRegularExpression(pattern: string, options: group.isIgnoreCase ? .caseInsensitive : [])
                    return SyntaxRegex(type: group.type, regex: regex)
                }
            } else {
                var pattern = definition.wordBoundaryPrefix
                pattern.append("(\(group.syntaxes.compactMap({ $0.escapedString }).joined(separator: "|")))")
                pattern.append(definition.wordBoundarySuffix)
                let regex = try! NSRegularExpression(pattern: pattern, options: group.isIgnoreCase ? .caseInsensitive : [])
                return [SyntaxRegex(type: group.type, regex: regex)]
            }
        }
        self.syntaxes = Set(syntaxes)

        // Initialize commentOut
        self.commentOut = definition.syntaxGroups
            .first(where: { $0.type == .comment && !$0.isMultiple })?.syntaxes.first?.open

        // Initialize commentOpen
        let commentOpen = definition.syntaxGroups
            .filter({ $0.type == .comment }).flatMap({ $0.syntaxes.compactMap({ $0.open }) })
        self.commentOpen = Set(commentOpen)

        // Initialize multilineSyntax
        let multilineSyntax = definition.syntaxGroups
            .filter({ $0.isMultiple && ($0.type == .comment || $0.type == .string) })
            .flatMap({ $0.syntaxes.flatMap({ [$0.open, $0.close].compactMap({ $0 }) }) })
        self.multilineSyntax = Set(multilineSyntax)

        // Initialize symbolicCharacter
        self.symbolicCharacter = CharacterSet(charactersIn: definition.symbolicCharacter)

        // Initialize wordRange
        let allowTokenPattern = definition.allowTokenPattern ?? "\\w"
        let wordRangePattern = "\(definition.wordBoundaryPrefix)[\(allowTokenPattern)]+?\(definition.wordBoundarySuffix)"
        self.wordRange = try! NSRegularExpression(pattern: wordRangePattern)

        // Initialize invalidRange
        let multiple = definition.syntaxGroups
            .filter({ $0.isMultiple && ($0.type == .comment || $0.type == .string) })
            .flatMap({ $0.syntaxes.filter({ $0.open != nil && $0.close != nil }).map({ "\($0.escapedOpen!).*?\($0.escapedClose!)" }) })
        let single = definition.syntaxGroups
            .filter({ !$0.isMultiple && ($0.type == .comment || $0.type == .string) })
            .flatMap({ $0.syntaxes.filter({ $0.open != nil }).map({ "\($0.escapedOpen!)[^\n]*?\($0.escapedClose ?? "$")" }) })
        let invalidRangePattern = "\((multiple.appending(single)).joined(separator: "|"))"
        self.invalidRange = try! NSRegularExpression(pattern: invalidRangePattern, options: [.dotMatchesLineSeparators, .anchorsMatchLines])

        // Initialize indentTrigger
        let indentTriggerPattern = "\(definition.escapedIndentTrigger.joined(separator: "|"))"
        self.indentTrigger = definition.indentTrigger.isEmpty ? nil : try! NSRegularExpression(pattern: indentTriggerPattern)

        // Initialize deindentTrigger
        let deindentTriggerPattern = "\(definition.escapedDeindentTrigger.joined(separator: "|"))"
        self.deindentTrigger = definition.deindentTrigger.isEmpty ? nil : try! NSRegularExpression(pattern: deindentTriggerPattern)
    }

}

extension SyntaxManager {

    // MARK: - Highlighting management

    typealias HighlightRange = (type: SyntaxType, range: NSRange)

    func highlight(text: String, range: NSRange) -> [HighlightRange] {
        // Get comment and string range
        var highlightRanges: [HighlightRange] = invalidRange.matches(in: text, range: text.range).map() {
            guard let range = Range($0.range, in: text) else {
                fatalError()
            }
            let matcheString = text[range]
            let isComment = commentOpen.contains(where: { matcheString.hasPrefix($0) })
            return (isComment ? .comment : .string, $0.range)
        }

        // Get other syntax range
        for syntax in syntaxes {
            let ranges: [HighlightRange] = syntax.regex.matches(in: text, range: range).compactMap() {
                result in
                guard !highlightRanges.contains(where: { $0.range.inRange(result.range) }) else {
                    return nil
                }
                return (syntax.type, result.range)
            }
            highlightRanges.append(contentsOf: ranges)
        }

        return highlightRanges
    }


    // MARK: - Word management

    func word(text: String) -> Bool {
        return !text.unicodeScalars.contains(where: { symbolicCharacter.contains($0) })
    }

    func wordRange(text: String, range: NSRange) -> NSRange? {
        return wordRange
            .matches(in: text, range: text.lineRange(for: range))
            .first(where: { $0.range.inRange(range) })
            .map({ $0.range })
    }

    func wordRanges(text: String, range: NSRange) -> [NSRange] {
        return wordRange
            .matches(in: text, range: range)
            .map({ $0.range })
    }


    // MARK: - Indent management

    var isBracketIndent: Bool {
        self.indentTrigger != nil && self.deindentTrigger != nil
    }

    func indent(text: String, range: NSRange) -> Int {
        guard let indentTrigger = self.indentTrigger, let deindentTrigger = self.deindentTrigger else {
            return .zero
        }

        // Get comment and string range
        let invalidRanges = Set(invalidRange.matches(in: text, range: text.range).map({ $0.range }))

        // Range not a comment, string
        let effective: (NSTextCheckingResult) -> Bool = {
            result in
            return !invalidRanges.contains(where: { $0.inRange(result.range) })
        }

        // Indentation level calculation
        let searchRange = NSMakeRange(.zero, range.upperBound)
        let indent = indentTrigger.matches(in: text, range: searchRange).filter(effective).count
        let deindent = deindentTrigger.matches(in: text, range: searchRange).filter(effective).count
        return max(indent - deindent, .zero)
    }

}
