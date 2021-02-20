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
    var uri: DocumentUri {
        didSet {
            self.fileName.text = uri.lastPathComponent
        }
    }
    /// Level of directory
    let level: Int

    /// Folding button
    private(set) weak var foldButton: WorkspaceFoldButton?
    /// Icon image view
    private(set) weak var fileIcon: UIImageView!
    /// File name label
    private(set) weak var fileName: UILabel!

    private let appearance = WorkspaceAppearance.self

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let identifier = WorkspaceViewCellIdentifier(reuseIdentifier ?? "") else {
            fatalError()
        }

        // Initialize
        self.uri = .bluff
        self.level = identifier.level
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        // Remove all subviews
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Avoid recalculation of unnecessary frames
        if identifier.isDirectory {
            let foldButton = createFoldButton()
            self.contentView.addSubview(foldButton)
            self.foldButton = foldButton
        }

        let fileIcon = createFileIcon(identifier)
        self.contentView.addSubview(fileIcon)
        self.fileIcon = fileIcon

        let fileName = createFileName(fileIcon.frame)
        self.contentView.addSubview(fileName)
        self.fileName = fileName
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createFoldButton() -> WorkspaceFoldButton {
        // Calc rect
        var foldButtonFrame = CGRect(origin: .zero, size: appearance.foldButtonSize)
        foldButtonFrame.origin.x = appearance.horizontalMargin
        foldButtonFrame.origin.x += appearance.indentWidth * CGFloat(level)
        foldButtonFrame.origin.x += appearance.foldMarkSize.width.centeringPoint(foldButtonFrame.width)
        foldButtonFrame.origin.y = appearance.cellHeight.centeringPoint(foldButtonFrame.height)

        // Create fold button
        return WorkspaceFoldButton(frame: foldButtonFrame)
    }

    private func createFileIcon(_ identifier: WorkspaceViewCellIdentifier) -> UIImageView {
        // Get icon image
        let icon: UIImage
        let config = UIImage.SymbolConfiguration(pointSize: appearance.fileIconPointSize, weight: appearance.fileIconWeight)
        switch (identifier.isFile, identifier.isDirectory, identifier.isLink, identifier.isHidden) {
        case (true, _, _, false):
            icon = UIImage(systemName: "doc.fill", withConfiguration: config)!
        case (true, _, _, true):
            icon = UIImage(systemName: "doc", withConfiguration: config)!
        case (_, true, _, false):
            icon = UIImage(systemName: "folder.fill", withConfiguration: config)!
        case (_, true, _, true):
            icon = UIImage(systemName: "folder", withConfiguration: config)!
        case (_, _, true, false):
            icon = UIImage(systemName: "arrowshape.turn.up.right.circle.fill", withConfiguration: config)!
        case (_, _, true, true):
            icon = UIImage(systemName: "arrowshape.turn.up.right.circle", withConfiguration: config)!
        default:
            icon = UIImage(systemName: "questionmark.circle", withConfiguration: config)!
        }

        var fileIconFrame = CGRect(origin: .zero, size: icon.size)
        fileIconFrame.origin.x = appearance.horizontalMargin
        fileIconFrame.origin.x += appearance.indentWidth * CGFloat(level)
        fileIconFrame.origin.x += appearance.foldMarkSize.width
        fileIconFrame.origin.x += 4
        fileIconFrame.origin.x += appearance.fileIconSize.width.centeringPoint(fileIconFrame.width)
        fileIconFrame.origin.y = appearance.cellHeight.centeringPoint(fileIconFrame.height)

        let fileIcon = UIImageView(frame: fileIconFrame)
        fileIcon.tintColor = appearance.fileIconColor
        fileIcon.image = icon
        return fileIcon
    }

    private func createFileName(_ fileIconFrame: CGRect) -> UILabel {
        var fileNameFrame = CGRect.zero
        fileNameFrame.origin.x = fileIconFrame.maxX
        fileNameFrame.origin.x += 5
        fileNameFrame.size.height = appearance.cellHeight

        let fileName = UILabel(frame: fileNameFrame)
        fileName.font = appearance.fileNameFont
        fileName.textColor = appearance.fileNameFontColor
        fileName.baselineAdjustment = .alignBaselines
        return fileName
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var fileNameFrame = fileName.frame
        fileNameFrame.size.width = bounds.width
        fileNameFrame.size.width -= fileNameFrame.minX
        fileNameFrame.size.width -= appearance.horizontalMargin
        fileName.frame = fileNameFrame
    }

}
