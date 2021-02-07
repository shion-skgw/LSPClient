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

    init(rootUri: DocumentUri) {
        self.uri = rootUri
        self.level = .zero
        self.type = .directory
        self.isHidden = false
        self.size = .zero
    }

    init(remoteUrl: NSURL, level: Int) {
        guard let documentUri = WorkspaceFile.documentUri(remoteUrl),
                let resourceValues = try? remoteUrl.resourceValues(forKeys: WorkspaceFile.resourceValueKeys) else {
            fatalError()
        }
        self.uri = documentUri
        self.level = level
        self.type = WorkspaceFile.fileType(resourceValues)
        self.isHidden = WorkspaceFile.isHidden(resourceValues)
        self.size = WorkspaceFile.fileSize(resourceValues)
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

    static func naturalOrdering(_ file1: Self, _ file2: Self) -> Bool {
        return file1.uri.path.localizedStandardCompare(file2.uri.path) == .orderedAscending
    }

    private static func documentUri(_ url: NSURL) -> DocumentUri? {
        guard let host = url.host else {
            return url as DocumentUri
        }
        return DocumentUri(string: url.absoluteString?.replacingOccurrences(of: host, with: "") ?? "")
    }

    private static func fileType(_ values: [URLResourceKey: Any]) -> FileType {
        if (values[.isSymbolicLinkKey] as? NSNumber)?.boolValue == true || (values[.isAliasFileKey] as? NSNumber)?.boolValue == true {
            return .link

        } else if (values[.isDirectoryKey] as? NSNumber)?.boolValue == true {
            return .directory

        } else if (values[.isRegularFileKey] as? NSNumber)?.boolValue == true {
            return .file

        } else {
            return .unknown
        }
    }

    private static func isHidden(_ values: [URLResourceKey: Any]) -> Bool {
        return (values[.isHiddenKey] as? NSNumber)?.boolValue == true
    }

    private static func fileSize(_ values: [URLResourceKey: Any]) -> Int {
        return (values[.fileSizeKey] as? NSNumber)?.intValue ?? .zero
    }

}

