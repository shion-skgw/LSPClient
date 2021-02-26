//
//  WorkspaceViewCell.swift
//  LSPClient
//
//  Created by Shion on 2021/02/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewCell: UITableViewCell {
    /// Folding button
    private(set) weak var foldButton: WorkspaceFoldButton?
    /// Icon image view
    private(set) weak var fileIcon: UIImageView!
    /// File name label
    private(set) weak var fileName: UILabel!

    /// Document URI
    var uri: DocumentUri {
        didSet {
            self.fileName.text = uri.lastPathComponent
        }
    }

    private let rowHeight: CGFloat = WorkspaceViewController.rowHeight
    private let leftMargin: CGFloat = 10
    private let rightMargin: CGFloat = 8
    private let indentWidth: CGFloat = 14
    private let foldMarkSize: CGSize = CGSize(width: 10, height: 10)
    private let fileIconSize: CGSize = CGSize(width: 22, height: 22)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let identifier = WorkspaceViewCellIdentifier(identifier: reuseIdentifier ?? "") else {
            fatalError()
        }

        // Initialize
        self.uri = .bluff
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Remove all subviews
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Folding button
        if identifier.isDirectory {
            let foldButton = createFoldButton(identifier.level)
            self.contentView.addSubview(foldButton)
            self.foldButton = foldButton
        }

        // Icon image view
        let fileIcon = createFileIcon(identifier)
        self.contentView.addSubview(fileIcon)
        self.fileIcon = fileIcon

        // File name label
        let fileName = createFileName(fileIcon.frame)
        self.contentView.addSubview(fileName)
        self.fileName = fileName
    }

    private func createFoldButton(_ level: Int) -> WorkspaceFoldButton {
        // Calc frame
        var foldButtonFrame = CGRect(x: .zero, y: .zero, width: rowHeight * 1.2, height: rowHeight)
        foldButtonFrame.origin.x = leftMargin
        foldButtonFrame.origin.x += indentWidth * CGFloat(level)
        foldButtonFrame.origin.x += foldMarkSize.width.centeringPoint(foldButtonFrame.width)
        foldButtonFrame.origin.y = rowHeight.centeringPoint(foldButtonFrame.height)

        // Create folding button
        let foldButton = WorkspaceFoldButton(frame: foldButtonFrame)
        foldButton.tintColor = .label
        foldButton.contentEdgeInsets.top = foldButtonFrame.height.centeringPoint(foldMarkSize.height)
        foldButton.contentEdgeInsets.bottom = foldButton.contentEdgeInsets.top
        foldButton.contentEdgeInsets.left = foldButtonFrame.width.centeringPoint(foldMarkSize.width)
        foldButton.contentEdgeInsets.right = foldButton.contentEdgeInsets.left
        return foldButton
    }

    private func createFileIcon(_ identifier: WorkspaceViewCellIdentifier) -> UIImageView {
        // Get icon image
        let icon: UIImage
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .thin)
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

        // Calc frame
        var fileIconFrame = CGRect(origin: .zero, size: icon.size)
        fileIconFrame.origin.x = leftMargin
        fileIconFrame.origin.x += indentWidth * CGFloat(identifier.level)
        fileIconFrame.origin.x += foldMarkSize.width
        fileIconFrame.origin.x += 6
        fileIconFrame.origin.x += fileIconSize.width.centeringPoint(fileIconFrame.width)
        fileIconFrame.origin.y = rowHeight.centeringPoint(fileIconFrame.height)

        // Create icon image view
        let fileIcon = UIImageView(frame: fileIconFrame)
        fileIcon.tintColor = .label
        fileIcon.image = icon
        return fileIcon
    }

    private func createFileName(_ fileIconFrame: CGRect) -> UILabel {
        // Calc frame
        var fileNameFrame = CGRect.zero
        fileNameFrame.origin.x = fileIconFrame.maxX
        fileNameFrame.origin.x += 6
        fileNameFrame.size.height = rowHeight

        // Create file name label
        let fileName = UILabel(frame: fileNameFrame)
        fileName.font = .systemFont
        fileName.textColor = .label
        return fileName
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Calc file name label width
        var fileNameWidth = bounds.width
        fileNameWidth -= fileName.frame.minX
        fileNameWidth -= rightMargin
        fileName.frame.size.width = fileNameWidth
    }

}
