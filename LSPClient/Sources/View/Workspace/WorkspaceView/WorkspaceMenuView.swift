//
//  WorkspaceMenuView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/07.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceMenuView: UIView {
    /// Close button
    private(set) weak var closeButton: UIButton!
    /// File add button
    private(set) weak var addButton: UIButton!
    /// File remove button
    private(set) weak var removeButton: UIButton!
    /// Scroll button
    private(set) weak var scrollButton: UIButton!
    /// Refresh button
    private(set) weak var refreshButton: UIButton!

    /// Button icon image point size
    private let iconPointSize: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Close button
        let closeButton = UIButton(frame: .zero)
        closeButton.setImage(UIImage.closeIcon(pointSize: iconPointSize, weight: .regular), for: .normal)
        closeButton.tintColor = .systemBlue
        self.addSubview(closeButton)
        self.closeButton = closeButton

        // File add button
        let addButton = createButton("plus.circle")
        self.addSubview(addButton)
        self.addButton = addButton

        // File remove button
        let removeButton = createButton("minus.circle")
        self.addSubview(removeButton)
        self.removeButton = removeButton

        // Scroll button
        let scrollButton = createButton("scope")
        self.addSubview(scrollButton)
        self.scrollButton = scrollButton

        // Refresh button
        let refreshButton = createButton("arrow.clockwise.circle")
        self.addSubview(refreshButton)
        self.refreshButton = refreshButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///
    /// Create button
    ///
    /// - Parameter iconName: SF Symbol name
    /// - Returns           : Button
    ///
    private func createButton(_ iconName: String) -> UIButton {
        let config = UIImage.SymbolConfiguration(pointSize: iconPointSize, weight: .regular)
        let icon = UIImage(systemName: iconName, withConfiguration: config)!
        let button = UIButton(frame: .zero)
        button.setImage(icon, for: .normal)
        button.tintColor = .systemBlue
        return button
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Close button
        leftAlignment(closeButton, 0)
        // File add button
        rightAlignment(addButton, 3)
        // File remove button
        rightAlignment(removeButton, 2)
        // Scroll button
        rightAlignment(scrollButton, 1)
        // Refresh button
        rightAlignment(refreshButton, 0)
    }

    ///
    /// Left alignment
    ///
    /// - Parameter button  : Button
    /// - Parameter position: Alignment position
    ///
    private func leftAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = CGRect(x: .zero, y: .zero, width: bounds.height, height: bounds.height)
        buttonFrame.origin.x = buttonFrame.width * position
        button.frame = buttonFrame
    }

    ///
    /// Right alignment
    ///
    /// - Parameter button  : Button
    /// - Parameter position: Alignment position
    ///
    private func rightAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = CGRect(x: .zero, y: .zero, width: bounds.height, height: bounds.height)
        buttonFrame.origin.x = bounds.width
        buttonFrame.origin.x -= buttonFrame.width * (position + 1)
        button.frame = buttonFrame
    }

}
