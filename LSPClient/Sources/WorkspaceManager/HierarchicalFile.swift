//
//  HierarchicalFile.swift
//  LSPClient
//
//  Created by Shion on 2021/02/03.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

struct HierarchicalFile {
    let uri: DocumentUri
    let level: Int
    let isDirectory: Bool
    let isLink: Bool
    let isHidden: Bool
    let size: Int
    var children: [HierarchicalFile]

    init(rootUri: DocumentUri) {
        self.uri = rootUri
        self.level = .zero
        self.isDirectory = true
        self.isLink = false
        self.isHidden = false
        self.size = .zero
        self.children = []
    }

    init(uri: DocumentUri, level: Int, isDirectory: Bool, isLink: Bool, isHidden: Bool, size: Int) {
        self.uri = uri
        self.level = level
        self.isDirectory = isDirectory
        self.isLink = isLink
        self.isHidden = isHidden
        self.size = size
        self.children = []
    }

}
