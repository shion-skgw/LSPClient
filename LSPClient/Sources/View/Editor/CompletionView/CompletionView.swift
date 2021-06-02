//
//  CompletionView.swift
//  LSPClient
//
//  Created by Shion on 2021/06/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionView: UIView {
    /// Completion item list view
    private(set) weak var itemList: UITableView!
    /// Documentation view
    private(set) weak var documentation: UITextView!

    /// Item row height
    private let rowHeight: CGFloat = CompletionViewController.rowHeight
    /// View border width
    private let borderWidth: CGFloat = 0.5
    /// Corner radius
    private let cornerRadius: CGFloat = 3

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        // Initialize self view
        super.init(frame: frame)
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius

        // Initialize completion item list view
        let itemList = ItemList()
        self.addSubview(itemList)
        self.itemList = itemList

        // Initialize documentation view
        let documentation = Documentation()
        self.addSubview(documentation)
        self.documentation = documentation
    }

    private func ItemList() -> UITableView {
        // Calc frame
        var frame = CGRect(origin: .zero, size: self.bounds.size)
        frame.size.height /= 2

        // Create view
        let view = UITableView(frame: frame, style: .plain)
        view.rowHeight = rowHeight
        view.estimatedRowHeight = .zero
        view.separatorStyle = .none
        return view
    }

    private func Documentation() -> UITextView {
        // Calc frame
        var frame = CGRect(origin: .zero, size: self.bounds.size)
        frame.origin.y += self.itemList.frame.height + borderWidth
        frame.size.height -= frame.minY

        // Create view
        let view = UITextView(frame: frame)
        view.isEditable = false
        view.isSelectable = false
        view.textContainer.lineBreakMode = .byCharWrapping
        return view
    }

    func set(_ codeStyle: CodeStyle) {
        // Self view
        self.backgroundColor = codeStyle.edgeColor
        self.layer.borderColor = codeStyle.edgeColor.cgColor

        // Completion item list view
        itemList.backgroundColor = codeStyle.backgroundColor
        itemList.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white

        // Documentation view
        documentation.font = .smallSystemFont
        documentation.textColor = codeStyle.fontColor.text.uiColor
        documentation.backgroundColor = codeStyle.backgroundColor
        documentation.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
    }

}
