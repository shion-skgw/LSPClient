//
//  CompletionViewCell.swift
//  LSPClient
//
//  Created by Shion on 2021/05/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewCell: UITableViewCell {
    /// Icon image view
    private(set) weak var symbolIcon: UIImageView!
    /// Completion text label
    private(set) weak var completionLabel: UILabel!

    private let symbolWidth: CGFloat = UIFont.systemFontSize * 1.4
    private let symbolPointSize: CGFloat = UIFont.systemFontSize

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let identifier = CompletionViewCellIdentifier(identifier: reuseIdentifier ?? "") else {
            fatalError()
        }

        // Initialize
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Icon image view
        let symbolIcon = createSymbolIcon(identifier)
        self.contentView.addSubview(symbolIcon)
        self.symbolIcon = symbolIcon

        // File name label
        let completionLabel = createCompletionLabel(identifier)
        self.contentView.addSubview(completionLabel)
        self.completionLabel = completionLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSymbolIcon(_ identifier: CompletionViewCellIdentifier) -> UIImageView {
        // Get icon image
        let icon = identifier.icon(size: symbolPointSize, weight: .medium)

        // Calc frame
        var symbolIconFrame = CGRect(origin: .zero, size: icon.size)
        symbolIconFrame.origin.x = symbolWidth.centeringPoint(symbolIconFrame.width)

        // Create icon image view
        let symbolIcon = UIImageView(frame: symbolIconFrame)
        symbolIcon.tintColor = identifier.iconColor
        symbolIcon.image = icon
        return symbolIcon
    }

    private func createCompletionLabel(_ identifier: CompletionViewCellIdentifier) -> UILabel {
        // Calc frame
        var completionLabelFrame = CGRect.zero
        completionLabelFrame.origin.x = symbolWidth

        // Create file name label
        return UILabel(frame: completionLabelFrame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Calc symbol icon frame
        var symbolIconFrame = symbolIcon.frame
        symbolIconFrame.origin.y = bounds.height.centeringPoint(symbolIconFrame.height)
        symbolIcon.frame = symbolIconFrame

        // Calc completion label frame
        var completionLabelFrame = completionLabel.frame
        completionLabelFrame.size.width = bounds.width - symbolWidth
        completionLabelFrame.size.height = bounds.height
        completionLabel.frame = completionLabelFrame
    }

    func set(codeStyle: CodeStyle) {
        self.completionLabel.font = codeStyle.font.uiFont
        self.completionLabel.textColor = codeStyle.fontColor.text.uiColor

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = codeStyle.highlightColor
        self.selectedBackgroundView = selectedBackgroundView
    }

    func set(label: String, deprecated: Bool) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.completionLabel.font ?? .systemFont,
            .foregroundColor: self.completionLabel.textColor ?? .black,
            .strikethroughStyle: deprecated ? 1 : 0
        ]
        self.completionLabel.attributedText = NSAttributedString(string: label, attributes: attributes)
    }

}
