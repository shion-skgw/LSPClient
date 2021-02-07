//
//  WorkspaceFile.swift
//  LSPClient
//
//  Created by Shion on 2021/02/04.
//  Copyright © 2021 Shion. All rights reserved.
//

struct WorkspaceFile {
    let uri: DocumentUri
    let level: Int
    let isDirectory: Bool
    let isLink: Bool
    let isHidden: Bool
    let size: Int

    var isFile: Bool {
        !self.isDirectory && !self.isLink
    }

    var cellReuseIdentifier: String {
        var identifier = String(self.level)
        if self.isDirectory { identifier.append(":isDirectory") }
        if self.isLink { identifier.append(":isLink") }
        if self.isHidden { identifier.append(":isHidden") }
        return identifier
    }

    init(file: HierarchicalFile) {
        self.uri = file.uri
        self.level = file.level
        self.isDirectory = file.isDirectory
        self.isLink = file.isLink
        self.isHidden = file.isHidden
        self.size = file.size
    }

    init?(cellReuseIdentifier identifier: String) {
        guard let level = Int(identifier.split(separator: ":").first ?? "") else {
            return nil
        }
        self.uri = .bluff
        self.level = level
        self.isDirectory = identifier.contains("isDirectory")
        self.isLink = identifier.contains("isLink")
        self.isHidden = identifier.contains("isHidden")
        self.size = .zero
    }
}
