//
//  EditorTabItem.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIButton

final class EditorTabItem: UIButton {
    /// Close button
    private(set) weak var closeButton: EditorTabCloseButton!
    /// File name label
    private(set) weak var fileName: UILabel!

    /// Active background color
    private(set) var activeColor: UIColor
    /// Inactive background color
    private(set) var inactiveColor: UIColor

    /// Document URI
    var uri: DocumentUri
    /// Active state
    var isActive: Bool {
        didSet {
            self.backgroundColor = self.isActive ? self.activeColor : self.inactiveColor
            self.closeButton.tintColor = self.isActive ? self.inactiveColor : self.activeColor
        }
    }
    /// Intrinsic content size
    override var intrinsicContentSize: CGSize {
        self.bounds.size
    }

    override init(frame: CGRect) {
        // Initialize
        self.activeColor = .white
        self.inactiveColor = .white
        self.uri = .bluff
        self.isActive = true
        super.init(frame: frame)

        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview() })

        // Close button
        let closeButton = createCloseButton()
        self.addSubview(closeButton)
        self.closeButton = closeButton

        // File name label
        let fileName = createFileName(closeButton.frame)
        self.addSubview(fileName)
        self.fileName = fileName

        // Design setting
        self.layer.cornerRadius = 3
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///
    /// Create close button
    ///
    /// - Returns: Close button
    ///
    private func createCloseButton() -> EditorTabCloseButton {
        // Calc frame
        var closeButtonFrame = CGRect(origin: .zero, size: frame.size)
        closeButtonFrame.size.width = frame.height

        // Create close button
        return EditorTabCloseButton(frame: closeButtonFrame)
    }

    ///
    /// Create file name label
    ///
    /// - Returns: File name label
    ///
    private func createFileName(_ closeButtonFrame: CGRect) -> UILabel {
        // Calc frame
        var fileNameFrame = CGRect(origin: .zero, size: frame.size)
        fileNameFrame.origin.x = closeButtonFrame.maxX + 2
        fileNameFrame.size.width -= fileNameFrame.minX + 4

        // Create file name label
        let fileName = UILabel(frame: fileNameFrame)
        fileName.font = UIFont.systemFont
        return fileName
    }

    ///
    /// Set code style
    ///
    /// - Parameter codeStyle: Code style
    ///
    func set(codeStyle: CodeStyle) {
        // Set title
        self.fileName.textColor = codeStyle.fontColor.text.uiColor

        // Set background color
        self.activeColor = codeStyle.activeTabColor.uiColor
        self.inactiveColor = codeStyle.inactiveTabColor.uiColor
        self.backgroundColor = self.isActive ? self.activeColor : self.inactiveColor
        self.closeButton.tintColor = self.isActive ? self.inactiveColor : self.activeColor
    }

}
