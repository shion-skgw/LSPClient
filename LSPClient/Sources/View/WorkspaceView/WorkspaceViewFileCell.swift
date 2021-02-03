//
//  WorkspaceViewFileCell.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

private let INDENT_WIDTH = CGFloat(16.0)
private let FOLD_WIDTH = CGFloat(10.0)
private let ICON_WIDTH = CGFloat(22.0)

final class WorkspaceViewFileCell: UITableViewCell {

    let uri: DocumentUri
    let level: Int
    let isFile: Bool

    init(uri: DocumentUri, isLink: Bool, isHidden: Bool, level: Int) {
        // Initialize
        self.uri = uri
        self.level = level
        self.isFile = !isLink
        super.init(style: .default, reuseIdentifier: "WorkspaceViewFileCell")

        // Image view
        self.imageView?.image = image(isLink, isHidden)
        self.imageView?.tintColor = .label

        // Text label
        self.textLabel?.text = uri.lastPathComponent
        self.textLabel?.font = UIFont.systemFont

        // Margin setting
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins.left = 6
        self.layoutMargins.right = 6
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func image(_ isLink: Bool, _ isHidden: Bool) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 16.0, weight: .light)
        let baseName = isLink ? "arrowshape.turn.up.right.circle" : "doc"
        return UIImage(systemName: baseName.appending(isHidden ? "" : ".fill"), withConfiguration: config)!
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        // Margin + Indent + Fold icon area width
        let originX = layoutMargins.left + (INDENT_WIDTH * CGFloat(level)) + FOLD_WIDTH

        // Icon area frame
        var imageViewFrame = imageView?.frame ?? .zero
        imageViewFrame.origin.x = originX + 5.0 + (ICON_WIDTH - imageViewFrame.width) / 2.0
        imageViewFrame.origin.y = (frame.height - imageViewFrame.height) / 2.0
        imageView?.frame = imageViewFrame

        // File area name frame
        var textLabelFrame = textLabel?.frame ?? .zero
        textLabelFrame.origin.x = originX + 5.0 + ICON_WIDTH + 4.0
        textLabelFrame.size.width = frame.width - textLabelFrame.origin.x - layoutMargins.left - layoutMargins.right
        textLabel?.frame = textLabelFrame
    }

}
