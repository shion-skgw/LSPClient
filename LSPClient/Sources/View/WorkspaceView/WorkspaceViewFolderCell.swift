//
//  WorkspaceViewFolderCell.swift
//  LSPClient
//
//  Created by Shion on 2021/02/03.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

private let INDENT_WIDTH = CGFloat(16.0)
private let FOLD_WIDTH = CGFloat(10.0)
private let ICON_WIDTH = CGFloat(22.0)

final class WorkspaceViewFolderCell: UITableViewCell {

    var uri: DocumentUri?
    let level: Int
    private(set) weak var foldIcon: WorkspaceFoldIcon!

//    init(file: WorkspaceFile) {
//        // Initialize
//        self.uri = file.uri
//        self.level = file.level
//        super.init(style: .default, reuseIdentifier: file.uri.absoluteString)
//
//        // Fold icon view
//        let foldIcon = WorkspaceFoldIcon()
//        foldIcon.tintColor = .label
//        self.contentView.addSubview(foldIcon)
//        self.foldIcon = foldIcon
//
//        // Image view
//        self.imageView?.image = image(file.isHidden)
//        self.imageView?.tintColor = .label
//
//        // Text label
//        self.textLabel?.text = uri.lastPathComponent
//        self.textLabel?.font = UIFont.systemFont
//
//        // Margin setting
//        self.preservesSuperviewLayoutMargins = false
//        self.layoutMargins.left = 6
//        self.layoutMargins.right = 6
//    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func image(_ isHidden: Bool) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 15.0, weight: .light)
        let name = isHidden ? "folder" : "folder.fill"
        return UIImage(systemName: name, withConfiguration: config)!
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Fold icon area frame
        var foldIconFrame = CGRect.zero
        foldIconFrame.origin.x = layoutMargins.left + INDENT_WIDTH * CGFloat(level)
        foldIconFrame.origin.y = (frame.height - FOLD_WIDTH) / 2.0
        foldIconFrame.size.width = FOLD_WIDTH
        foldIconFrame.size.height = FOLD_WIDTH
        foldIcon.frame = foldIconFrame

        // Icon area frame
        var imageViewFrame = imageView?.frame ?? .zero
        imageViewFrame.origin.x = foldIconFrame.maxX + 5.0 + (ICON_WIDTH - imageViewFrame.width) / 2.0
        imageViewFrame.origin.y = (frame.height - imageViewFrame.height) / 2.0
        imageView?.frame = imageViewFrame

        // File area name frame
        var textLabelFrame = textLabel?.frame ?? .zero
        textLabelFrame.origin.x = foldIconFrame.maxX + 5.0 + ICON_WIDTH + 4.0
        textLabelFrame.size.width = frame.width - textLabelFrame.origin.x - layoutMargins.left - layoutMargins.right
        textLabel?.frame = textLabelFrame
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // Reuse identifier
        let identifier = reuseIdentifier ?? "0"

        // Initialize
        self.level = Int(identifier.split(separator: ":").first!)!
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Fold icon view
        let foldIcon = WorkspaceFoldIcon()
        foldIcon.tintColor = .label
        self.contentView.addSubview(foldIcon)
        self.foldIcon = foldIcon

        // Image view
        self.imageView?.image = image(identifier.contains("isHidden"))
        self.imageView?.tintColor = .label

        // Text label
        self.textLabel?.text = ""
        self.textLabel?.font = UIFont.systemFont

        // Margin setting
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins.left = 6
        self.layoutMargins.right = 6
    }

}
