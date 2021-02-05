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

    init(file: HierarchicalFile) {
        self.uri = file.uri
        self.level = file.level
        self.isDirectory = file.isDirectory
        self.isLink = file.isLink
        self.isHidden = file.isHidden
    }

    var cellReuseIdentifier: String {
        var identifier = String(self.level)
        if self.isDirectory { identifier.append(":isDirectory") }
        if self.isLink { identifier.append(":isLink") }
        if self.isHidden { identifier.append(":isHidden") }
        return identifier
    }

}

