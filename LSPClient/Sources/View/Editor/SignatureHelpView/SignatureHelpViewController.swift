//
//  SignatureHelpViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/24.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SignatureHelpViewController: UIViewController, FloatingViewType {
    private(set) weak var signatureHelpView: SignatureHelpView!
    private var documentationText: DocumentationText!

    typealias LSPResultType = SignatureHelp
    var invokedRange: NSRange = .notFound

    override func loadView() {
        let signatureHelpView = SignatureHelpView(frame: CGRect(origin: .zero, size: viewSize))
        signatureHelpView.isHidden = true
        self.signatureHelpView = signatureHelpView
        self.view = signatureHelpView

        refreshCodeStyle()
    }

    override func viewDidLoad() {
        // NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()

        signatureHelpView.set(codeStyle)
        documentationText = DocumentationText(codeStyle: codeStyle)
    }

    func willShow(_ result: SignatureHelp) -> Bool {
        guard let signature = result.signatures.first else {
            return false
        }
        let description = signature.documentation?.string
        let parameters: [DocumentationText.ParameterDescription]? = signature.parameters?.map() {
            switch $0.label {
            case .string(let name):
                return (name, $0.documentation?.string)
            case .number(let start, let end):
                let range = NSMakeRange(start, end - start)
                let name = signature.label.range.inRange(range) ? signature.label[range] : nil
                return (name, $0.documentation?.string)
            }
        }
        let documentation = documentationText.create(signature: signature.label, description: description, parameters: parameters)
        signatureHelpView.attributedText = documentation
        return true
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
