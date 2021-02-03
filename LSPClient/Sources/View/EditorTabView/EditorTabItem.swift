//
//  EditorTabItem.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIButton

final class EditorTabItem: UIButton {

    private var activeColor: UIColor = .white
    private var inactiveColor: UIColor = .white
    private(set) weak var closeButton: UIButton!

    var isActive: Bool = true {
        didSet {
            self.backgroundColor = isActive ? activeColor : inactiveColor
        }
    }

    override var intrinsicContentSize: CGSize {
        self.frame.size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialize close button
        let closeButton = UIButton(type: .close)
        closeButton.frame.origin.x = (frame.height - closeButton.frame.width) / 2
        closeButton.frame.origin.y = (frame.height - closeButton.frame.height) / 2
        self.addSubview(closeButton)
        self.closeButton = closeButton

        // Layout title label
        var titleLabelFrame = CGRect.zero
        titleLabelFrame.size.height = frame.height
        titleLabelFrame.size.width = frame.width - frame.height
        titleLabelFrame.origin.x = frame.height
        self.titleLabel?.frame = titleLabelFrame
        self.titleLabel?.textAlignment = .center

        // Design setting
        self.layer.cornerRadius = 3.0
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(title: String) {
        self.setTitle(title, for: .normal) // TODO: フォントが反映させるか確認
    }

    func set(codeStyle: CodeStyle) {
        // Set title
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
            .foregroundColor: codeStyle.fontColor.text.uiColor
        ]
        let title = NSAttributedString(string: self.titleLabel?.text ?? "Untitled", attributes: attributes)
        self.setAttributedTitle(title, for: .normal)

        // Set background color
        self.activeColor = codeStyle.activeTabColor.uiColor
        self.inactiveColor = codeStyle.inactiveTabColor.uiColor
        self.backgroundColor = self.isActive ? self.activeColor : self.inactiveColor
    }

    func set(tagNumber: Int) {
        self.tag = tagNumber
        self.closeButton.tag = tagNumber
    }

}
