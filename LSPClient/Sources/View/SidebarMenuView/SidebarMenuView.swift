//
//  SidebarMenuView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarMenuView: UIView {

    private let appearance = SidebarMenuAppearance.self

    private(set) weak var settingButton: UIButton!
    private(set) weak var workspaceButton: UIButton!
    private(set) weak var consoleButton: UIButton!
    private(set) weak var diagnosticButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let settingButton = createButton("ellipsis.circle.fill")
        self.addSubview(settingButton)
        self.settingButton = settingButton

        let workspaceButton = createButton("folder.fill")
        self.addSubview(workspaceButton)
        self.workspaceButton = workspaceButton

        let consoleButton = createButton("terminal.fill")
        self.addSubview(consoleButton)
        self.consoleButton = consoleButton

        let diagnosticButton = createButton("checkmark.shield.fill")
        self.addSubview(diagnosticButton)
        self.diagnosticButton = diagnosticButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createButton(_ iconName: String) -> UIButton {
        let config = UIImage.SymbolConfiguration(pointSize: appearance.iconPointSize, weight: appearance.iconWeight)
        let icon = UIImage(systemName: iconName, withConfiguration: config)!
        let buttonFrame = CGRect(origin: .zero, size: appearance.buttonSize)
        let button = UIButton(frame: buttonFrame)
        button.setImage(icon, for: .normal)
        button.tintColor = appearance.iconColor
        return button
    }

    override func layoutSubviews() {
        topAlignment(settingButton, 0)
        topAlignment(workspaceButton, 1)
        bottomAlignment(consoleButton, 1)
        bottomAlignment(diagnosticButton, 0)
    }

    private func topAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = button.frame
        buttonFrame.origin.y = buttonFrame.height * position
        button.frame = buttonFrame
    }

    private func bottomAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = button.frame
        buttonFrame.origin.y = bounds.height - buttonFrame.height * (position + 1)
        button.frame = buttonFrame
    }

}
