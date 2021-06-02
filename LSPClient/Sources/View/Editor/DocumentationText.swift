//
//  DocumentationText.swift
//  LSPClient
//
//  Created by Shion on 2021/06/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class DocumentationText {

    typealias ParameterDescription = (name: String?, description: String?)

    private let headlineAttribute: [NSAttributedString.Key: Any]
    private let signatureAttribute: [NSAttributedString.Key: Any]
    private let descriptionAttribute: [NSAttributedString.Key: Any]
    private let parameterAttribute: [NSAttributedString.Key: Any]
    private let parameterDescriptionAttribute: [NSAttributedString.Key: Any]

    private static let newlineRegex = try! NSRegularExpression(pattern: "\\R+")
    private static let spaceRegex = try! NSRegularExpression(pattern: "^\\s+", options: .anchorsMatchLines)

    init(codeStyle: CodeStyle) {
        let font = UIFont.smallSystemFont
        let boldFont = UIFont.smallBoldSystemFont
        let codeFont = codeStyle.font.withSize(UIFont.smallSystemFontSize)
        let fontColor = codeStyle.fontColor.text.uiColor
        let indentSize = UIFont.smallSystemFontSize
        let spacing = UIFont.smallSystemFontSize / 2

        self.headlineAttribute = NSAttributedString.makeAttributes(font: boldFont, color: fontColor)

        var signatureAttribute = NSAttributedString.makeAttributes(font: codeFont, color: fontColor)
        signatureAttribute.merge(NSAttributedString.makeParagraphStyle(afterSpacing: spacing), uniquingKeysWith: { $1 })
        self.signatureAttribute = signatureAttribute

        var descriptionAttribute = NSAttributedString.makeAttributes(font: font, color: fontColor)
        descriptionAttribute.merge(NSAttributedString.makeParagraphStyle(afterSpacing: spacing), uniquingKeysWith: { $1 })
        self.descriptionAttribute = descriptionAttribute

        self.parameterAttribute = NSAttributedString.makeAttributes(font: codeFont, color: fontColor)

        var parameterDescriptionAttribute = NSAttributedString.makeAttributes(font: font, color: fontColor)
        parameterDescriptionAttribute.merge(NSAttributedString.makeParagraphStyle(headIndent: indentSize), uniquingKeysWith: { $1 })
        self.parameterDescriptionAttribute = parameterDescriptionAttribute
    }

    func create(signature: String?, deprecated: Bool = false,
            description: String?, parameters: [ParameterDescription]?) -> NSAttributedString {
        let attrString = NSMutableAttributedString()
        if let signature = self.signature(signature ?? "", deprecated) {
            attrString.append(signature)
        }
        if let description = self.description(description ?? "") {
            attrString.append(description)
        }
        if let parameters = self.parameters(parameters ?? []) {
            attrString.append(parameters)
        }
        if attrString.length > .zero {
            attrString.replaceCharacters(in: NSMakeRange(attrString.length - 1, 1), with: "")
        }
        return attrString
    }

    private func signature(_ text: String, _ deprecated: Bool) -> NSAttributedString? {
        guard text.isNotEmpty else {
            return nil
        }
        let attrString = NSMutableAttributedString(string: "Signature\n", attributes: headlineAttribute)
        if deprecated {
            let attributes = signatureAttribute.merging(NSAttributedString.makeStrikeThrough(style: .single), uniquingKeysWith: { $1 })
            attrString.append(NSAttributedString(string: "\(text)\n", attributes: attributes))
        } else {
            attrString.append(NSAttributedString(string: "\(text)\n", attributes: signatureAttribute))
        }
        return attrString
    }

    private func description(_ text: String) -> NSAttributedString? {
        guard text.isNotEmpty else {
            return nil
        }
        let attrString = NSMutableAttributedString(string: "Description\n", attributes: headlineAttribute)
        attrString.append(NSAttributedString(string: "\(Self.normalize(text))\n", attributes: descriptionAttribute))
        return attrString
    }

    private func parameters(_ params: [ParameterDescription]) -> NSAttributedString? {
        guard params.isNotEmpty else {
            return nil
        }
        let attrString = NSMutableAttributedString(string: "Parameters\n", attributes: headlineAttribute)
        params.forEach() {
            attrString.append(NSAttributedString(string: "\u{22C5} \($0.name ?? "?")\n", attributes: parameterAttribute))
            if let description = $0.description {
                attrString.append(NSAttributedString(string: "\(Self.normalize(description))\n", attributes: parameterDescriptionAttribute))
            }
        }
        return attrString
    }

    private static func normalize(_ text: String) -> String {
        let text = NSMutableString(string: text)
        newlineRegex.replaceMatches(in: text, range: NSMakeRange(.zero, text.length), withTemplate: "\n")
        spaceRegex.replaceMatches(in: text, range: NSMakeRange(.zero, text.length), withTemplate: "")
        return text as String
    }

}
