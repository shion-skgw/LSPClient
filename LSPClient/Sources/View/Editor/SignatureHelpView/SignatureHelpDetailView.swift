//
//  SignatureHelpDetailView.swift
//  LSPClient
//
//  Created by Shion on 2021/05/30.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SignatureHelpDetailView: UITextView {

    private let paramBullet = "\u{22C5}"
    private var paramAttribute: [NSAttributedString.Key: Any] = [:]
    private var descriptionAttribute: [NSAttributedString.Key: Any] = [:]
    private var detailAttribute: [NSAttributedString.Key: Any] = [:]

    func set(codeStyle: CodeStyle) {
        self.paramAttribute = [
            .font: codeStyle.font.uiFont,
            .foregroundColor: codeStyle.fontColor.text.uiColor,
        ]

        let descriptionParagraph = NSMutableParagraphStyle()
        descriptionParagraph.firstLineHeadIndent = codeStyle.font.size * 2
        descriptionParagraph.headIndent = codeStyle.font.size * 2
        self.descriptionAttribute = [
            .font: UIFont.systemFont(ofSize: codeStyle.font.size),
            .foregroundColor: codeStyle.fontColor.text.uiColor,
            .paragraphStyle: descriptionParagraph,
        ]

        self.detailAttribute = [
            .font: UIFont.systemFont(ofSize: codeStyle.font.size),
            .foregroundColor: codeStyle.fontColor.text.uiColor,
        ]

        // UITextView
        self.font = codeStyle.font.uiFont
        self.textColor = codeStyle.fontColor.text.uiColor
        self.backgroundColor = codeStyle.backgroundColor
        self.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
    }

    func set(detail: String, params: [SignatureInformation.ParamInfo]?) {
        var components = params?.flatMap({ [name($0), description($0)] }).compactMap({ $0 }) ?? []
        if let last = components.last {
            last.append(NSAttributedString(string: "\n"))
        }
        components.append(detailText(detail))

        let body = NSMutableAttributedString()
        components.forEach() {
            body.append($0)
        }

        self.attributedText = body
    }

    private func name(_ param: SignatureInformation.ParamInfo) -> NSMutableAttributedString {
        let name = paramBullet.appending(param.name ?? "*unknown*")
        return NSMutableAttributedString(string: name.appending("\n"), attributes: paramAttribute)
    }

    private func description(_ param: SignatureInformation.ParamInfo) -> NSMutableAttributedString? {
        guard let description = param.description else {
            return nil
        }
        return NSMutableAttributedString(string: description.appending("\n"), attributes: descriptionAttribute)
    }

    private func detailText(_ text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: detailAttribute)
    }

}
