//
//  WorkspaceViewCellIdentifier.swift
//  LSPClient
//
//  Created by Shion on 2021/02/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

struct WorkspaceViewCellIdentifier {
    let level: Int
    let isFile: Bool
    let isDirectory: Bool
    let isLink: Bool
    let isHidden: Bool

    var string: String {
        var identifier = String(self.level)
        if self.isLink {
            identifier.append(":link")
        } else if self.isDirectory {
            identifier.append(":directory")
        } else if self.isFile {
            identifier.append(":file")
        }
        return identifier.appending(self.isHidden ? ":hidden" : "")
    }

    init(_ file: WorkspaceFile) {
        self.level = file.level
        self.isFile = file.type == .file
        self.isDirectory = file.type == .directory
        self.isLink = file.type == .link
        self.isHidden = file.isHidden
    }

    init?(_ identifier: String) {
        guard let level = Int(identifier.split(separator: ":").first ?? "") else {
            return nil
        }
        self.level = level
        self.isFile = identifier.contains("file")
        self.isDirectory = identifier.contains("directory")
        self.isLink = identifier.contains("link")
        self.isHidden = identifier.contains("hidden")
    }
}
