//
//  WorkspaceMenuView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/07.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceMenuView: UIView {

    private let appearance = WorkspaceAppearance.self

    private(set) weak var closeButton: UIButton!
    private(set) weak var addButton: UIButton!
    private(set) weak var removeButton: UIButton!
    private(set) weak var scrollButton: UIButton!
    private(set) weak var refreshButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let closeButton = UIButton.closeButton(frame: CGRect(origin: .zero, size: appearance.menuButtonSize), pointSize: appearance.menuIconPointSize, weight: appearance.menuIconWeight)
        self.addSubview(closeButton)
        self.closeButton = closeButton

        let addButton = createButton("plus.circle")
        self.addSubview(addButton)
        self.addButton = addButton

        let removeButton = createButton("minus.circle")
        self.addSubview(removeButton)
        self.removeButton = removeButton

        let scrollButton = createButton("scope")
        self.addSubview(scrollButton)
        self.scrollButton = scrollButton

        let refreshButton = createButton("arrow.clockwise.circle")
        self.addSubview(refreshButton)
        self.refreshButton = refreshButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createButton(_ iconName: String) -> UIButton {
        let config = UIImage.SymbolConfiguration(pointSize: appearance.menuIconPointSize, weight: appearance.menuIconWeight)
        let icon = UIImage(systemName: iconName, withConfiguration: config)!
        let buttonFrame = CGRect(origin: .zero, size: appearance.menuButtonSize)
        let button = UIButton(frame: buttonFrame)
        button.setImage(icon, for: .normal)
        button.tintColor = appearance.menuIconColor
        return button
    }

    override func layoutSubviews() {
        leftAlignment(closeButton, 0)
        rightAlignment(addButton, 3)
        rightAlignment(removeButton, 2)
        rightAlignment(scrollButton, 1)
        rightAlignment(refreshButton, 0)
    }

    private func leftAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = button.frame
        buttonFrame.origin.x = appearance.menuButtonSize.width * position
        button.frame = buttonFrame
    }

    private func rightAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = button.frame
        buttonFrame.origin.x = bounds.width - appearance.menuButtonSize.width * (position + 1)
        button.frame = buttonFrame
    }

    override func draw(_ rect: CGRect) {
        var separatorRect = bounds
        separatorRect.origin.y = separatorRect.height - appearance.separatorWeight
        separatorRect.size.height = appearance.separatorWeight

        let cgContext = UIGraphicsGetCurrentContext()!
        cgContext.setFillColor(appearance.separatorColor.cgColor)
        cgContext.fill(separatorRect)
    }

}
