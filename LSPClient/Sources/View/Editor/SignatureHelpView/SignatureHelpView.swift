//
//  SignatureHelpView.swift
//  LSPClient
//
//  Created by Shion on 2021/06/03.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SignatureHelpView: UITextView {

    /// View border width
    private let borderWidth: CGFloat = 0.5
    /// Corner radius
    private let cornerRadius: CGFloat = 3

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.isEditable = false
        self.isSelectable = false
        self.textContainer.lineBreakMode = .byCharWrapping
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(_ codeStyle: CodeStyle) {
        self.font = .smallSystemFont
        self.textColor = codeStyle.fontColor.text.uiColor
        self.backgroundColor = codeStyle.backgroundColor
        self.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
        self.layer.borderColor = codeStyle.edgeColor.cgColor
    }

}
