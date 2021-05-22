//
//  WorkspaceViewCellIdentifier.swift
//  LSPClient
//
//  Created by Shion on 2021/02/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIImage

struct WorkspaceViewCellIdentifier {
    let level: Int
    let isFile: Bool
    let isDirectory: Bool
    let isLink: Bool
    let isHidden: Bool

    var string: String {
        var identifier = String(self.level)
        if self.isFile {
            identifier.append(":file")
        } else if self.isDirectory {
            identifier.append(":directory")
        } else if self.isLink {
            identifier.append(":link")
        }
        return self.isHidden ? identifier.appending(":hidden") : identifier
    }

    init(file: WorkspaceFile) {
        self.level = file.level
        self.isFile = file.type == .file
        self.isDirectory = file.type == .directory
        self.isLink = file.type == .link
        self.isHidden = file.isHidden
    }

    init?(identifier: String) {
        guard let level = Int(identifier.split(separator: ":").first ?? "") else {
            return nil
        }
        self.level = level
        self.isFile = identifier.contains("file")
        self.isDirectory = identifier.contains("directory")
        self.isLink = identifier.contains("link")
        self.isHidden = identifier.contains("hidden")
    }

    func icon(config: UIImage.SymbolConfiguration) -> UIImage {
        switch (isFile, isDirectory, isLink, isHidden) {
        case (true, _, _, false):
            return UIImage(systemName: "doc.fill", withConfiguration: config)!
        case (true, _, _, true):
            return UIImage(systemName: "doc", withConfiguration: config)!
        case (_, true, _, false):
            return UIImage(systemName: "folder.fill", withConfiguration: config)!
        case (_, true, _, true):
            return UIImage(systemName: "folder", withConfiguration: config)!
        case (_, _, true, false):
            return UIImage(systemName: "arrowshape.turn.up.right.circle.fill", withConfiguration: config)!
        case (_, _, true, true):
            return UIImage(systemName: "arrowshape.turn.up.right.circle", withConfiguration: config)!
        default:
            return UIImage(systemName: "questionmark.circle", withConfiguration: config)!
        }
    }

}
