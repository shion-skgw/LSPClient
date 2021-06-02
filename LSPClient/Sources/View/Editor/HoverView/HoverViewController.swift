//
//  HoverViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/24.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class HoverViewController: UIViewController, FloatingViewType {
    private(set) weak var hoverView: HoverView!
    private var documentationText: DocumentationText!

    typealias LSPResultType = Hover
    var invokedRange: NSRange = .notFound

    override func loadView() {
        let hoverView = HoverView(frame: CGRect(origin: .zero, size: viewSize))
        hoverView.isHidden = true
        self.hoverView = hoverView
        self.view = hoverView

        refreshCodeStyle()
    }

    override func viewDidLoad() {
        // NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()

        hoverView.set(codeStyle)
        documentationText = DocumentationText(codeStyle: codeStyle)
    }

    func willShow(_ result: Hover) -> Bool {
        guard result.contents.kind == .plaintext else {
            return false
        }
        let documentation = documentationText.create(signature: nil, description: result.contents.value, parameters: nil)
        hoverView.attributedText = documentation
        return true
    }

}
