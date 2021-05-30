//
//  HoverViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/24.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class HoverViewController: UIViewController, FloatingViewType {

    private(set) weak var detailView: UITextView!

    let viewSize: CGSize = CGSize(width: 260, height: 180)
    private var codeStyle: CodeStyle!
    var invokedRange: NSRange = .notFound

    override func loadView() {
        let detailView = UITextView(frame: CGRect(origin: .zero, size: viewSize))
        detailView.isHidden = true
        detailView.isEditable = false
        detailView.isSelectable = false
        detailView.textContainer.lineBreakMode = .byCharWrapping
        self.detailView = detailView
        self.view = detailView

        refreshCodeStyle()
    }

    override func viewDidLoad() {
        borderSetting()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    @objc private func refreshCodeStyle() {
        // Load code style
        codeStyle = CodeStyle.load()

        // Update view border

        // Update completion detail view
        detailView.font = .systemFont(ofSize: codeStyle.font.size)
        detailView.textColor = codeStyle.fontColor.text.uiColor
        detailView.backgroundColor = codeStyle.backgroundColor
        detailView.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
        detailView.layer.borderColor = codeStyle.edgeColor.cgColor
    }

    func show(hover: Hover, caretRect: CGRect) {
        // Initialize
        detailView.text = hover.contents.value
        show(caretRect: caretRect)
    }

}
