//
//  WorkspaceViewCell.swift
//  LSPClient
//
//  Created by Shion on 2021/02/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

private let INDENT_WIDTH = CGFloat(16)
private let FOLD_WIDTH = CGFloat(10)
private let ICON_WIDTH = CGFloat(22)
private let MARGIN = CGFloat(6)

final class WorkspaceViewCell: UITableViewCell {

    var uri: DocumentUri!
    let level: Int
    let isFile: Bool
    private(set) weak var foldButton: WorkspaceFoldButton?

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
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Fold button
        if isDirectory {
            let foldButton = WorkspaceFoldButton(frame: .zero)
            foldButton.setImage(.triangleDown, for: .normal)
            foldButton.tintColor = .label
            self.contentView.addSubview(foldButton)
            self.foldButton = foldButton
        }

        // Image view
        self.imageView?.image = iconImage(isDirectory, isLink, isHidden)
        self.imageView?.tintColor = .label

        // Text label
        self.textLabel?.text = ""
        self.textLabel?.font = UIFont.systemFont

        // Margin setting
        self.preservesSuperviewLayoutMargins = false
//        self.layoutMargins.left = 6 使うとなぞに描画がブレる (Simulator iPod touch 7th iOS 14.4)
//        self.layoutMargins.right = 6
    }

    private func iconImage(_ isDirectory: Bool, _ isLink: Bool, _ isHidden: Bool) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 15.0, weight: .light)
        switch (isDirectory, isLink, isHidden) {
        case (true, false, false):
            return UIImage(systemName: "folder.fill", withConfiguration: config)!
        case (true, false, true):
            return UIImage(systemName: "folder", withConfiguration: config)!
        case (false, true, false):
            return UIImage(systemName: "arrowshape.turn.up.right.circle.fill", withConfiguration: config)!
        case (false, true, true):
            return UIImage(systemName: "arrowshape.turn.up.right.circle", withConfiguration: config)!
        case (false, false, false):
            return UIImage(systemName: "doc.fill", withConfiguration: config)!
        case (false, false, true):
            return UIImage(systemName: "doc", withConfiguration: config)!
        default:
            return UIImage(systemName: "questionmark.circle", withConfiguration: config)!
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Fold icon area frame
        var foldButtonFrame = CGRect.zero
//        foldButtonFrame.origin.x = layoutMargins.left + INDENT_WIDTH * CGFloat(level)
        foldButtonFrame.origin.x = MARGIN + INDENT_WIDTH * CGFloat(level)
        foldButtonFrame.origin.y = (frame.height - FOLD_WIDTH) / 2.0
        foldButtonFrame.size.width = FOLD_WIDTH
        foldButtonFrame.size.height = FOLD_WIDTH
        foldButton?.frame = foldButtonFrame

        // Icon area frame
        var imageViewFrame = imageView?.frame ?? .zero
        imageViewFrame.origin.x = foldButtonFrame.maxX + 5.0 + (ICON_WIDTH - imageViewFrame.width) / 2.0
        imageViewFrame.origin.y = (frame.height - imageViewFrame.height) / 2.0
        imageView?.frame = imageViewFrame

        // File area name frame
        var textLabelFrame = textLabel?.frame ?? .zero
        textLabelFrame.origin.x = foldButtonFrame.maxX + 5.0 + ICON_WIDTH + 4.0
//        textLabelFrame.size.width = frame.width - textLabelFrame.origin.x - layoutMargins.left - layoutMargins.right
        textLabelFrame.size.width = frame.width - textLabelFrame.origin.x - MARGIN - MARGIN
        textLabel?.frame = textLabelFrame
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
