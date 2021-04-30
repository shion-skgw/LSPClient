//
//  PreferenceMenuView.swift
//  LSPClient
//
//  Created by Shion on 2021/03/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class PreferenceMenuView: UIView {
    /// Server config button
    private(set) weak var serverConfigButton: UIButton!
    /// Appearance button
    private(set) weak var appearanceButton: UIButton!
    /// Code style button
    private(set) weak var codeStyleButton: UIButton!

    /// Button icon image point size
    private let iconPointSize: CGFloat = 20
    /// Button icon image weight
    private let iconWeight: UIImage.SymbolWeight = .regular
    /// Active background color
    private let activeColor: UIColor = .secondarySystemBackground

    override init(frame: CGRect) {
        super.init(frame: frame)

        let serverConfigButton = createButton("externaldrive.connected.to.line.below")
        self.addSubview(serverConfigButton)
        self.serverConfigButton = serverConfigButton

        let appearanceButton = createButton("eyes")
        self.addSubview(appearanceButton)
        self.appearanceButton = appearanceButton

        let codeStyleButton = createButton("list.bullet.rectangle")
        self.addSubview(codeStyleButton)
        self.codeStyleButton = codeStyleButton

        toggleHighlight(button: appearanceButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Server config button
        topAlignment(serverConfigButton, 0)
        // Appearance button
        topAlignment(appearanceButton, 1)
        // Code style button
        topAlignment(codeStyleButton, 2)
    }

    ///
    /// Create button
    ///
    /// - Parameter iconName: SF Symbol name
    /// - Returns           : Button
    ///
    private func createButton(_ iconName: String) -> UIButton {
        let config = UIImage.SymbolConfiguration(pointSize: iconPointSize, weight: iconWeight)
        let icon = UIImage(systemName: iconName, withConfiguration: config)!
        let button = UIButton(frame: .zero)
        button.setImage(icon, for: .normal)
        button.tintColor = .systemBlue
        return button
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

    func toggleHighlight(button: UIButton) {
        self.subviews.forEach({ $0.backgroundColor = $0 == button ? activeColor : nil })
    }

    func isSelected(button: UIButton) -> Bool {
        self.subviews.first(where: { $0 == button })?.backgroundColor != nil
    }

}
