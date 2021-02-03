//
//  WorkspaceManager.swift
//  LSPClient
//
//  Created by Shion on 2021/01/23.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

private let INCLUDING_KEYS: [URLResourceKey] = [ .isDirectoryKey, .isSymbolicLinkKey, .isAliasFileKey, .isHiddenKey, .fileSizeKey, ]

final class WorkspaceManager {

    static let shared: WorkspaceManager = WorkspaceManager()

    private(set) var workspaceName: String
    private(set) var workspaceRootUri: DocumentUri
    private(set) var remoteRootUrl: URL

    ///
    /// Local workspace root URL
    ///
    var localRootUrl: URL {
        guard let applicationSupport = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first,
                let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError()
        }
        var url = URL(fileURLWithPath: applicationSupport, isDirectory: true)
        url.appendPathComponent(bundleIdentifier, isDirectory: true)
        url.appendPathComponent(workspaceName, isDirectory: true)
        return url
    }

    ///
    /// Local original workspace root URL
    ///
    var originalRootUrl: URL {
        localRootUrl.appendingPathComponent("orig", isDirectory: true)
    }

    ///
    /// Local edit workspace root URL
    ///
    var editRootUrl: URL {
        localRootUrl.appendingPathComponent("edit", isDirectory: true)
    }

    ///
    /// Initialize
    ///
    private init() {
        self.workspaceName = ""
        self.workspaceRootUri = URL(string: "file:///")!
        self.remoteRootUrl = URL(string: "file:///")!
    }

    ///
    /// Initialize
    ///
    /// - Parameter workspaceName   : Workspace name
    /// - Parameter rootUri         : Language server workspace root URI
    /// - Parameter host            : Language server host
    /// - Parameter port            : Language server port
    ///
    func initialize(workspaceName: String, rootUri: DocumentUri, host: String, port: Int) {
        guard let remoteWorkspaceUrl = URL(string: "file://\(host):\(port)\(rootUri.path)/") else {
            fatalError()
        }
        self.workspaceName = workspaceName
        self.workspaceRootUri = rootUri
        self.remoteRootUrl = remoteWorkspaceUrl
    }

    ///
    /// Fetch workspace files
    ///
    /// - Returns                   : Workspace files
    ///
    func fetchWorkspaceFiles() -> [WorkspaceFile] {
        guard let enumerator = FileManager.default.enumerator(at: remoteRootUrl, includingPropertiesForKeys: INCLUDING_KEYS) else {
            fatalError()
        }

        var files: [WorkspaceFile] = []
        for element in enumerator {
            guard let url = element as? NSURL,
                    let documentUri = documentUri(url),
                    let properties = try? url.resourceValues(forKeys: INCLUDING_KEYS) else {
                continue
            }
            let isDirectory = properties[.isDirectoryKey] as? NSNumber == NSNumber(true)
            let isLink = properties[.isSymbolicLinkKey] as? NSNumber == NSNumber(true)
            let isAlias = properties[.isAliasFileKey] as? NSNumber == NSNumber(true)
            let fileType: WorkspaceFile.FileType = isDirectory ? .directory : isLink || isAlias ? .link : .file

            let pathLevel = documentUri.pathComponents.count - workspaceRootUri.pathComponents.count
            let isHidden = properties[.isHiddenKey] as? NSNumber == NSNumber(true)

            let file = WorkspaceFile(uri: documentUri, level: pathLevel, type: fileType, isHidden: isHidden)
            files.append(file)
        }

        return files.sorted(by: { $0.uri.path.localizedStandardCompare($1.uri.path) == .orderedAscending })
    }


    private func documentUri(_ remoteUrl: NSURL) -> DocumentUri? {
        if let host = remoteUrl.host, let absoluteString = remoteUrl.absoluteString {
            return DocumentUri(string: absoluteString.replacingOccurrences(of: host, with: ""))
        }
        return remoteUrl as DocumentUri
    }


    func copy(documentUri: DocumentUri, source: Source, destination: Source) {
        guard source != destination else {
            fatalError()
        }

        // Source file URL
        var sourceUrl: URL
        switch source {
        case .remote:   sourceUrl = remoteRootUrl
        case .original: sourceUrl = originalRootUrl
        case .edit:     sourceUrl = editRootUrl
        }
        sourceUrl.appendPathComponent(relativePath(documentUri), isDirectory: false)

        // Destination file URL
        var destinationUrl: URL
        switch destination {
        case .remote:   destinationUrl = remoteRootUrl
        case .original: destinationUrl = originalRootUrl
        case .edit:     destinationUrl = editRootUrl
        }
        destinationUrl.appendPathComponent(relativePath(documentUri), isDirectory: false)
    }

    private func relativePath(_ documentUri: DocumentUri) -> String {
        return documentUri.absoluteString.replacingOccurrences(of: workspaceRootUri.absoluteString, with: "")
    }

}

extension WorkspaceManager {

    enum Source {
        case remote
        case original
        case edit
    }

}

