//
//  WorkspaceManager.swift
//  LSPClient
//
//  Created by Shion on 2021/01/23.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

private let INCLUDING_KEYS: [URLResourceKey] = [ .isDirectoryKey, .isSymbolicLinkKey, .isAliasFileKey, .isHiddenKey, ]

final class WorkspaceManager {
    /// WorkspaceManager shared instance
    static let shared: WorkspaceManager = WorkspaceManager()
    /// Any workspace name
    private(set) var workspaceName: String
    /// Language server workspace root URI
    private(set) var workspaceRootUri: DocumentUri
    /// Remote workspace root URL
    private(set) var remoteRootUrl: URL

    ///
    /// Local workspace root URL
    /// e.g. /Library/Application Support/Bundle identifier/Workspace name/
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
    /// e.g. /Library/Application Support/Bundle identifier/Workspace name/orig/
    ///
    var originalRootUrl: URL {
        localRootUrl.appendingPathComponent("orig", isDirectory: true)
    }

    ///
    /// Local edit workspace root URL
    /// e.g. /Library/Application Support/Bundle identifier/Workspace name/edit/
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
    func fetchFileHierarchy() -> HierarchicalFile {
        guard let enumerator = FileManager.default.enumerator(at: remoteRootUrl, includingPropertiesForKeys: INCLUDING_KEYS) else {
            fatalError()
        }

        var hierarchicalFile = HierarchicalFile(rootUri: workspaceRootUri)

        enumerator.compactMap({ $0 as! URL })
            .compactMap({ documentUri($0) })
            .sorted(by: localizedStandardOrder)
            .forEach({ parseFileHierarchy($0, &hierarchicalFile) })

        return hierarchicalFile
    }


    private func documentUri(_ remoteUrl: URL) -> DocumentUri? {
        guard let host = remoteUrl.host else {
            return remoteUrl as DocumentUri
        }
        return DocumentUri(string: remoteUrl.absoluteString.replacingOccurrences(of: host, with: ""))
    }


    private func parseFileHierarchy(_ target: URL, _ current: inout HierarchicalFile) {
        // Get path components
        let targetComponents = target.pathComponents
        let currentComponents = current.uri.pathComponents

        if currentComponents.count < targetComponents.count - 1 {
            let childUri = current.uri.appendingPathComponent(targetComponents[currentComponents.count], isDirectory: true)

            if current.children.last?.uri != childUri {
                let level = childUri.pathComponents.count - workspaceRootUri.pathComponents.count
                let childFile = HierarchicalFile(uri: childUri, level: level, isDirectory: true, isLink: false, isHidden: false)
                current.children.append(childFile)
            }

            parseFileHierarchy(target, &current.children[current.children.count - 1])

        } else {
            guard let properties = try? target.resourceValues(forKeys: Set(INCLUDING_KEYS)) else {
                fatalError()
//            return
            }

            let level = targetComponents.count - workspaceRootUri.pathComponents.count
            let isDirectory = properties.isDirectory ?? false
            let isLink = properties.isSymbolicLink == true || properties.isAliasFile == true
            let isHidden = properties.isHidden ?? false
            let childFile = HierarchicalFile(uri: target, level: level, isDirectory: isDirectory, isLink: isLink, isHidden: isHidden)
            current.children.append(childFile)
        }
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

