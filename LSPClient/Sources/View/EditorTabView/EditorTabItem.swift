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
    private(set) weak var fileNameLabel: UILabel!

    var isActive: Bool = true {
        didSet {
            self.backgroundColor = isActive ? activeColor : inactiveColor
        }
    }

    override var intrinsicContentSize: CGSize {
        self.bounds.size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview() })

        // Close button area size
        let closeButtonAreaWidth = frame.height
        let closeButtonAreaHeight = frame.height

        // Initialize close button
        let closeButton = UIButton(type: .close)
        closeButton.frame.origin.x = closeButtonAreaWidth.centeringPoint(closeButton.frame.width)
        closeButton.frame.origin.y = closeButtonAreaHeight.centeringPoint(closeButton.frame.height)
        self.addSubview(closeButton)
        self.closeButton = closeButton

        // Initialize Name label
        let nameLabel = UILabel(frame: .zero)
        nameLabel.frame.origin.x = closeButtonAreaWidth + 4.0
        nameLabel.frame.size.height = frame.height
        nameLabel.frame.size.width = frame.width - nameLabel.frame.origin.x - 2.0
        nameLabel.textAlignment = .left
        self.addSubview(nameLabel)
        self.fileNameLabel = nameLabel

        // Design setting
        self.layer.cornerRadius = 3.0
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(title: String) {
        self.fileNameLabel.text = title // TODO: フォントが反映させるか確認
    }

    func set(codeStyle: CodeStyle) {
        // Set title
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont,
            .foregroundColor: codeStyle.fontColor.text.uiColor
        ]
        let title = NSAttributedString(string: self.fileNameLabel.text ?? "Untitled", attributes: attributes)
        self.fileNameLabel.attributedText = title

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
