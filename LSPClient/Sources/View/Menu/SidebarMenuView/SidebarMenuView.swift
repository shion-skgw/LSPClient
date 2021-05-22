//
//  SidebarMenuView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarMenuView: UIView {
    /// Setting button
    private(set) weak var settingButton: UIButton!
    /// Workspace button
    private(set) weak var workspaceButton: UIButton!
    /// Console button
    private(set) weak var consoleButton: UIButton!
    /// Diagnostic button
    private(set) weak var diagnosticButton: UIButton!

    /// Button icon image point size
    private let iconPointSize: CGFloat = 20

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Setting button
        let settingButton = createButton("ellipsis.circle.fill")
        self.addSubview(settingButton)
        self.settingButton = settingButton

        // Workspace button
        let workspaceButton = createButton("folder.fill")
        self.addSubview(workspaceButton)
        self.workspaceButton = workspaceButton

        // Console button
        let consoleButton = createButton("terminal.fill")
        self.addSubview(consoleButton)
        self.consoleButton = consoleButton

        // Diagnostic button
        let diagnosticButton = createButton("checkmark.shield.fill")
        self.addSubview(diagnosticButton)
        self.diagnosticButton = diagnosticButton
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

        // Setting button
        topAlignment(settingButton, 0)
        // Workspace button
        topAlignment(workspaceButton, 1)
        // Console button
        bottomAlignment(consoleButton, 1)
        // Diagnostic button
        bottomAlignment(diagnosticButton, 0)
    }

    ///
    /// Top alignment
    ///
    /// - Parameter button  : Button
    /// - Parameter position: Alignment position
    ///
    private func topAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = CGRect(x: .zero, y: .zero, width: bounds.width, height: bounds.width)
        buttonFrame.origin.y = buttonFrame.height * position
        button.frame = buttonFrame
    }

    ///
    /// Bottom alignment
    ///
    /// - Parameter button  : Button
    /// - Parameter position: Alignment position
    ///
    private func bottomAlignment(_ button: UIButton, _ position: CGFloat) {
        var buttonFrame = CGRect(x: .zero, y: .zero, width: bounds.width, height: bounds.width)
        buttonFrame.origin.y = bounds.height
        buttonFrame.origin.y -= buttonFrame.height * (position + 1)
        button.frame = buttonFrame
    }

}
