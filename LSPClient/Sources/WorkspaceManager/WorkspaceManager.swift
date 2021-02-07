//
//  WorkspaceManager.swift
//  LSPClient
//
//  Created by Shion on 2021/02/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

final class WorkspaceManager {
    typealias ResourceIdentifier = (NSCopying & NSSecureCoding & NSObjectProtocol)

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
    /// Initialize
    ///
    private init() {
        self.workspaceName = ""
        self.workspaceRootUri = .bluff
        self.remoteRootUrl = .bluff
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

    func fetchWorkspaceFiles(skipsHidden: Bool) -> [WorkspaceFile] {
        guard let enumerator = FileManager.default.enumerator(at: remoteRootUrl,
                includingPropertiesForKeys: WorkspaceFile.resourceValueKeys, options: skipsHidden ? .skipsHiddenFiles : []) else {
            fatalError()
        }

        let workspaceRootLevel = workspaceRootUri.pathComponents.count

        var files = enumerator.compactMap({ $0 as! NSURL })
            .compactMap({ WorkspaceFile(remoteUrl: $0, level: ($0.pathComponents?.count ?? .zero) - workspaceRootLevel) })
            .sorted(by: WorkspaceFile.naturalOrdering)

        files.insert(WorkspaceFile(rootUri: workspaceRootUri), at: 0)

        return files
    }

}
