//
//  WorkspaceViewCell.swift
//  LSPClient
//
//  Created by Shion on 2021/02/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewCell: UITableViewCell {
    /// Document URI
    var uri: DocumentUri!
    /// Level of directory
    let level: Int
    /// Whether to open with Editor
    let isFile: Bool

    /// Folding button
    private(set) weak var foldButton: WorkspaceFoldButton?
    /// Icon image view
    private(set) weak var iconView: UIImageView!
    /// File name label
    private(set) weak var nameLabel: UILabel!

    private let cellHeight: CGFloat = UIFont.systemFontSize * 2.5
    private let indentWidth: CGFloat = 14
    private let foldButtonWidth: CGFloat = 10
    private let foldButtonHeight: CGFloat = 10
    private let iconAreaWidth: CGFloat = 22
    private let widthMargin: CGFloat = 8

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let identifier = reuseIdentifier,
                let level = Int(identifier.split(separator: ":").first ?? "") else {
            self.level = 0
            self.isFile = false
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            return
        }

        // Element type
        let isDirectory = identifier.contains("isDirectory")
        let isLink = identifier.contains("isLink")
        let isHidden = identifier.contains("isHidden")

        // Initialize
        self.level = level
        self.isFile = !isDirectory && !isLink
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        // Remove all subviews
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Avoid recalculation of unnecessary frames
        if isDirectory {
            addFoldButton()
        }
        addIconView(isDirectory, isLink, isHidden)
        addNameLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addFoldButton() {
        // Calc fold button frame
        var foldButtonFrame = CGRect.zero
        foldButtonFrame.origin.x = widthMargin + indentWidth * CGFloat(level)
        foldButtonFrame.origin.y = (cellHeight - foldButtonWidth) / 2.0
        foldButtonFrame.size.width = foldButtonWidth
        foldButtonFrame.size.height = foldButtonHeight

        // Initialize fold button
        let foldButton = WorkspaceFoldButton(frame: foldButtonFrame)
        foldButton.setImage(.triangleDown, for: .normal)
        foldButton.tintColor = .label
        self.contentView.addSubview(foldButton)
        self.foldButton = foldButton
    }

    private func addIconView(_ isDirectory: Bool, _ isLink: Bool, _ isHidden: Bool) {
        // Get icon image
        let icon: UIImage
        let config = UIImage.SymbolConfiguration(pointSize: 15.0, weight: .light)
        switch (isDirectory, isLink, isHidden) {
        case (true, false, false):
            icon = UIImage(systemName: "folder.fill", withConfiguration: config)!
        case (true, false, true):
            icon = UIImage(systemName: "folder", withConfiguration: config)!
        case (false, true, false):
            icon = UIImage(systemName: "arrowshape.turn.up.right.circle.fill", withConfiguration: config)!
        case (false, true, true):
            icon = UIImage(systemName: "arrowshape.turn.up.right.circle", withConfiguration: config)!
        case (false, false, false):
            icon = UIImage(systemName: "doc.fill", withConfiguration: config)!
        case (false, false, true):
            icon = UIImage(systemName: "doc", withConfiguration: config)!
        default:
            icon = UIImage(systemName: "questionmark.circle", withConfiguration: config)!
        }

        // Calc origin X (Margin + Indent + Fold button)
        let originX = widthMargin + indentWidth * CGFloat(level) + foldButtonWidth

        // Calc icon image frame
        var iconViewFrame = CGRect(origin: .zero, size: icon.size)
        iconViewFrame.origin.x = originX + 4.0 + (iconAreaWidth - icon.size.width) / 2.0
        iconViewFrame.origin.y = (cellHeight - icon.size.height) / 2.0

        // Initialize icon image
        let iconView = UIImageView(frame: iconViewFrame)
        iconView.image = icon
        iconView.tintColor = .label
        self.contentView.addSubview(iconView)
        self.iconView = iconView
    }

    private func addNameLabel() {
        // Calc name label frame (Width calc at layoutSubviews)
        let nameLabelFrame = CGRect(x: iconView.frame.maxX + 5.0, y: .zero, width: .zero, height: cellHeight)

        // Initialize name label
        let nameLabel = UILabel(frame: nameLabelFrame)
        nameLabel.font = UIFont.systemFont
        nameLabel.baselineAdjustment = .alignBaselines
        self.contentView.addSubview(nameLabel)
        self.nameLabel = nameLabel
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if nameLabel.frame.size.width == .zero {
            nameLabel.frame.size.width = frame.width - nameLabel.frame.minX - widthMargin
        }
    }

}
