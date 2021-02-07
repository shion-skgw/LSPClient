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
    var uri: DocumentUri! {
        didSet {
            self.nameLabel.text = uri.lastPathComponent
        }
    }
    /// Level of directory
    let level: Int

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
    private let iconPointSize: CGFloat = 15
    private let iconAreaWidth: CGFloat = 22
    private let widthMargin: CGFloat = 8

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let file = WorkspaceFile(cellReuseIdentifier: reuseIdentifier ?? "") else {
            fatalError()
        }

        // Initialize
        self.level = file.level
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        // Remove all subviews
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Avoid recalculation of unnecessary frames
        if file.isDirectory {
            addFoldButton()
        }
        addIconView(file)
        addNameLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addFoldButton() {
        // Calc fold button frame
        var foldButtonFrame = CGRect.zero
        foldButtonFrame.origin.x = widthMargin + indentWidth * CGFloat(level)
        foldButtonFrame.origin.y = cellHeight.centeringPoint(foldButtonHeight)
        foldButtonFrame.size.width = foldButtonWidth
        foldButtonFrame.size.height = foldButtonHeight

        // Initialize fold button
        let foldButton = WorkspaceFoldButton(frame: foldButtonFrame)
        foldButton.setImage(.triangleDown, for: .normal)
        foldButton.tintColor = .label
        self.contentView.addSubview(foldButton)
        self.foldButton = foldButton
    }

    private func addIconView(_ file: WorkspaceFile) {
        // Get icon image
        let icon: UIImage
        let config = UIImage.SymbolConfiguration(pointSize: iconPointSize, weight: .light)
        switch (file.isDirectory, file.isLink, file.isHidden) {
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
        iconViewFrame.origin.x = originX + 4.0 + iconAreaWidth.centeringPoint(icon.size.width)
        iconViewFrame.origin.y = cellHeight.centeringPoint(icon.size.height)

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
        nameLabel.frame.size.width = frame.width - nameLabel.frame.minX - widthMargin
    }

}
