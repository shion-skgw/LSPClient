//
//  WorkspaceViewDirectoryCell.swift
//  LSPClient
//
//  Created by Shion on 2021/02/03.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

private let INDENT_WIDTH = CGFloat(16.0)
private let ICON_WIDTH = CGFloat(22.0)
private let FOLD = "▶︎"
private let UNFOLD = "▼"

final class WorkspaceViewDirectoryCell: UITableViewCell {

    let uri: DocumentUri
    let level: Int
    private(set) weak var foldLabel: UILabel?

    var isFold: Bool {
        didSet {
            self.foldLabel?.text = isFold ? FOLD : UNFOLD
        }
    }

    init(uri: DocumentUri, isHidden: Bool, level: Int) {
        // Initialize
        self.uri = uri
        self.level = level
        self.isFold = false
        super.init(style: .default, reuseIdentifier: "WorkspaceViewDirectoryCell")

        // Margin setting
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins.left = 6
        self.layoutMargins.right = 6

        // Fold label
        let foldLabel = UILabel()
        foldLabel.text = UNFOLD
        foldLabel.font = UIFont.systemFont
        foldLabel.textAlignment = .center
        self.contentView.addSubview(foldLabel)
        self.foldLabel = foldLabel

        // Image view
        self.imageView?.image = image(isHidden)

        // Text label
        self.textLabel?.text = uri.lastPathComponent
        self.textLabel?.font = UIFont.systemFont
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func image(_ isHidden: Bool) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 16.0, weight: .light)
        let name = isHidden ? "folder" : "folder.fill"
        let image = UIImage(systemName: name, withConfiguration: config)!
        return image
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Fold icon area frame
        var foldLabelFrame = CGRect.zero
        foldLabelFrame.origin.x = layoutMargins.left + INDENT_WIDTH * CGFloat(level)
        foldLabelFrame.size.width = UIFont.systemFont.pointSize
        foldLabelFrame.size.height = frame.height
        foldLabel?.frame = foldLabelFrame

        // Icon area frame
        var imageViewFrame = imageView?.frame ?? .zero
        imageViewFrame.origin.x = foldLabelFrame.maxX + 3.0 + (ICON_WIDTH - imageViewFrame.width) / 2.0
        imageView?.frame = imageViewFrame

        // File area name frame
        var textLabelFrame = textLabel?.frame ?? .zero
        textLabelFrame.origin.x = foldLabelFrame.maxX + 3.0 + ICON_WIDTH + 4.0
        textLabelFrame.size.width = frame.width - textLabelFrame.origin.x - layoutMargins.left - layoutMargins.right
        textLabel?.frame = textLabelFrame
    }

}
