//
//  SignatureHelpViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/24.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SignatureHelpViewController: UIViewController, FloatingViewType {

    private(set) weak var informationView: UITextView!

    private var headlineAttribute: [NSAttributedString.Key: Any] = [:]
    private var signatureAttribute: [NSAttributedString.Key: Any] = [:]
    private var descriptionAttribute: [NSAttributedString.Key: Any] = [:]
    private var parameterAttribute: [NSAttributedString.Key: Any] = [:]
    private var parameterDescriptionAttribute: [NSAttributedString.Key: Any] = [:]

    let viewSize: CGSize = CGSize(width: 260, height: 180)
    var invokedRange: NSRange = .notFound

    override func loadView() {
        let informationView = UITextView(frame: CGRect(origin: .zero, size: viewSize))
        informationView.isHidden = true
        informationView.isEditable = false
        informationView.isSelectable = false
        informationView.textContainer.lineBreakMode = .byCharWrapping
        self.informationView = informationView
        self.view = informationView

        refreshCodeStyle()
    }

    override func viewDidLoad() {
        borderSetting()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    @objc private func refreshCodeStyle() {
        // Load code style
        let codeStyle = CodeStyle.load()

        // Update view border
        informationView.backgroundColor = codeStyle.backgroundColor
        informationView.layer.borderColor = codeStyle.edgeColor.cgColor

        let fontSize = UIFont.smallSystemFontSize
        let indentSize = UIFont.smallSystemFontSize

        self.headlineAttribute = [
            .font: UIFont.smallBoldSystemFont,
            .foregroundColor: codeStyle.fontColor.text.uiColor
        ]

        self.signatureAttribute = [
            .font: codeStyle.font.withSize(fontSize),
            .foregroundColor: codeStyle.fontColor.text.uiColor,
            .paragraphStyle: IndentParagraphStyle(head: indentSize)
        ]

        self.descriptionAttribute = [
            .font: UIFont.smallSystemFont,
            .foregroundColor: codeStyle.fontColor.text.uiColor,
            .paragraphStyle: IndentParagraphStyle(head: indentSize)
        ]

        self.parameterAttribute = [
            .font: codeStyle.font.withSize(fontSize),
            .foregroundColor: codeStyle.fontColor.text.uiColor,
            .paragraphStyle: IndentParagraphStyle(head: indentSize)
        ]

        self.parameterDescriptionAttribute = [
            .font: UIFont.smallSystemFont,
            .foregroundColor: codeStyle.fontColor.text.uiColor,
            .paragraphStyle: IndentParagraphStyle(head: indentSize * 2)
        ]
    }

    func show(signatures: SignatureHelp, caretRect: CGRect) {
        guard let signature = signatures.signatures.first else {
            fatalError()
        }

        informationView.attributedText = information(signature)
        show(caretRect: caretRect)
    }

    private func information(_ information: SignatureInformation) -> NSAttributedString {
        let body = NSMutableAttributedString()
        if let signature = signature(information) {
            body.append(signature)
        }
        if let description = description(information) {
            body.append(description)
        }
        if let parameters = parameters(information) {
            body.append(parameters)
        }
        if body.length != .zero {
            body.replaceCharacters(in: NSMakeRange(body.length - 1, 1), with: "")
        }
        return body
    }

    private func signature(_ information: SignatureInformation) -> NSAttributedString? {
        guard information.label.isNotEmpty else {
            return nil
        }
        let body = NSMutableAttributedString(string: "Signature\n", attributes: headlineAttribute)
        body.append(NSAttributedString(string: "\(information.label)\n\n", attributes: signatureAttribute))
        return body
    }

    private func description(_ information: SignatureInformation) -> NSAttributedString? {
        guard let description = information.documentation?.string else {
            return nil
        }
        let body = NSMutableAttributedString(string: "Documentation\n", attributes: headlineAttribute)
        body.append(NSAttributedString(string: "\(description)\n\n", attributes: descriptionAttribute))
        return body
    }

    private func parameters(_ information: SignatureInformation) -> NSAttributedString? {
        guard let parameters = information.params, parameters.isNotEmpty else {
            return nil
        }
        let body = NSMutableAttributedString(string: "Parameter\n", attributes: headlineAttribute)
        parameters.forEach() {
            let name = "\u{22C5} \($0.name ?? "unknown")\n"
            body.append(NSAttributedString(string: name, attributes: parameterAttribute))
            if let description = $0.description {
                body.append(NSAttributedString(string: "\(description)\n", attributes: parameterDescriptionAttribute))
            }
        }
        return body
    }

}

extension SignatureInformation {

    typealias ParamInfo = (name: String?, description: String?)

    var params: [ParamInfo]? {
        return self.parameters?.map() {
            switch $0.label {
            case .string(let name):
                return (name, $0.documentation?.string)
            case .number(let start, let end):
                let range = NSMakeRange(start, end - start)
                let name = self.label.range.inRange(range) ? self.label[range] : nil
                return (name, $0.documentation?.string)
            }
        }
    }

}

extension SignatureHelp.Documentation {

    var string: String? {
        switch self {
        case .string(let text):
            return text
        case .markup(let content):
            return content.kind == .plaintext ? content.value : nil
        }
    }

}
