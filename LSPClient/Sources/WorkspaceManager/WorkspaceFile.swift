//
//  WorkspaceFile.swift
//  LSPClient
//
//  Created by Shion on 2021/02/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

struct WorkspaceFile {
    let uri: DocumentUri
    let level: Int
    let type: FileType
    let isHidden: Bool
    let size: Int

    init(remoteUrl: URL, level: Int) {
        guard let resourceValues = try? remoteUrl.resourceValues(forKeys: Set(WorkspaceFile.resourceValueKeys)) else {
            fatalError()
        }
        self.uri = remoteUrl.standardizedFileURL
        self.level = level
        self.type = WorkspaceFile.fileType(resourceValues)
        self.isHidden = resourceValues.isHidden == true
        self.size = resourceValues.fileSize ?? .zero
    }

}

extension WorkspaceFile {

    enum FileType {
        case file
        case directory
        case link
        case unknown
    }

    static let resourceValueKeys: [URLResourceKey] = [
        .isRegularFileKey,
        .isDirectoryKey,
        .isSymbolicLinkKey,
        .isAliasFileKey,
        .isHiddenKey,
        .fileSizeKey
    ]

    private static func fileType(_ values: URLResourceValues) -> FileType {
        if values.isSymbolicLink == true || values.isAliasFile == true {
            return .link
        } else if values.isDirectory == true {
            return .directory
        } else if values.isRegularFile == true {
            return .file
        } else {
            return .unknown
        }
    }

}
