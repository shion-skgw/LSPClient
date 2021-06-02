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
    private(set) weak var icon: UIImageView!
    /// Completion text label
    private(set) weak var label: UILabel!

    /// Item row height
    private let rowHeight: CGFloat = CompletionViewController.rowHeight
    private let symbolWidth: CGFloat = UIFont.systemFontSize * 1.6
    private let symbolPointSize: CGFloat = UIFont.systemFontSize

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let identifier = CompletionViewCellIdentifier(identifier: reuseIdentifier ?? "") else {
            fatalError()
        }

        // Initialize
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectedBackgroundView = UIView()
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Icon image view
        let icon = Icon(identifier)
        self.contentView.addSubview(icon)
        self.icon = icon

        // File name label
        let label = Label(identifier)
        self.contentView.addSubview(label)
        self.label = label
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func Icon(_ identifier: CompletionViewCellIdentifier) -> UIImageView {
        // Get icon image
        let icon = identifier.icon(size: symbolPointSize, weight: .medium)

        // Calc frame
        var frame = CGRect(origin: .zero, size: icon.size)
        frame.origin.x = symbolWidth.centeringPoint(frame.width)
        frame.origin.y = rowHeight.centeringPoint(frame.height)

        // Create view
        let view = UIImageView(frame: frame)
        view.tintColor = identifier.iconColor
        view.image = icon
        return view
    }

    private func Label(_ identifier: CompletionViewCellIdentifier) -> UILabel {
        // Calc frame
        var frame = CGRect.zero
        frame.origin.x = symbolWidth
        frame.size.height = rowHeight

        // Create view
        return UILabel(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Calc completion label frame
        var labelFrame = CGRect(origin: .zero, size: bounds.size)
        labelFrame.origin.x = symbolWidth
        labelFrame.size.width -= symbolWidth
        label.frame = labelFrame
    }

    func set(_ codeStyle: CodeStyle) {
        self.label.font = codeStyle.font.uiFont
        self.label.textColor = codeStyle.fontColor.text.uiColor

        self.selectedBackgroundView?.backgroundColor = codeStyle.highlightColor
    }

}
