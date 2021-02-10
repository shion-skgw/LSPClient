//
//  SidebarView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarView: UIView {

    private let appearance = Appearance.Sidebar.self
    private(set) weak var workspaceButton: UIButton!
    private(set) weak var consoleButton: UIButton!
    private(set) weak var diagnosticsButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let workspaceButton = createButton("folder.fill")
        self.addSubview(workspaceButton)
        self.workspaceButton = workspaceButton

        let consoleButton = createButton("terminal.fill")
        self.addSubview(consoleButton)
        self.consoleButton = consoleButton

        let diagnosticsButton = createButton("checkmark.shield.fill")
        self.addSubview(diagnosticsButton)
        self.diagnosticsButton = diagnosticsButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createButton(_ iconName: String) -> UIButton {
        let config = UIImage.SymbolConfiguration(pointSize: appearance.iconPointSize, weight: .medium)
        let icon = UIImage(systemName: iconName, withConfiguration: config)!
        let buttonFrame = CGRect(origin: .zero, size: appearance.buttonSize)
        let button = UIButton(frame: buttonFrame)
        button.setImage(icon, for: .normal)
        button.tintColor = appearance.iconColor
        return button
    }

    override func layoutSubviews() {
        let viewSize = bounds.size
        let buttonAreaWidth = viewSize.width
        let buttonAreaHeight = buttonAreaWidth

        // Top alignment

        var workspaceButtonFrame = workspaceButton.frame
        workspaceButtonFrame.origin.x = buttonAreaWidth.centeringPoint(workspaceButtonFrame.width)
        workspaceButtonFrame.origin.y = buttonAreaHeight.centeringPoint(workspaceButtonFrame.height)
        workspaceButton.frame = workspaceButtonFrame

        // Bottom alignment

        var consoleButtonFrame = consoleButton.frame
        consoleButtonFrame.origin.x = buttonAreaWidth.centeringPoint(consoleButtonFrame.width)
        consoleButtonFrame.origin.y = viewSize.height - buttonAreaHeight + buttonAreaHeight.centeringPoint(consoleButtonFrame.height)
        consoleButton.frame = consoleButtonFrame

        var diagnosticsButtonFrame = diagnosticsButton.frame
        diagnosticsButtonFrame.origin.x = buttonAreaWidth.centeringPoint(diagnosticsButtonFrame.width)
        diagnosticsButtonFrame.origin.y = viewSize.height - (buttonAreaHeight * 2.0) + buttonAreaHeight.centeringPoint(diagnosticsButtonFrame.height)
        diagnosticsButton.frame = diagnosticsButtonFrame
    }
}
