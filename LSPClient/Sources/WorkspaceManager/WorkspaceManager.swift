//
//  WorkspaceManager.swift
//  LSPClient
//
//  Created by Shion on 2021/02/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation
import CryptoKit

final class WorkspaceManager {
    /// WorkspaceManager shared instance
    static let shared: WorkspaceManager = WorkspaceManager()

    /// Any workspace name
    private(set) var workspaceName: String
    /// Language server workspace root URI
    private(set) var workspaceRootUri: DocumentUri
    /// Remote workspace root URL
    private(set) var remoteRootUrl: URL
    private var remoteFileDigests: [DocumentUri: SHA256Digest]

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
        self.remoteFileDigests = [:]
    }

    ///
    /// Initialize
    ///
    /// - Parameter workspaceName   : Workspace name
    /// - Parameter remoteRootUrl   : Language server workspace root URL
    ///
    func initialize(workspaceName: String, remoteRootUrl: URL) {
        self.workspaceName = workspaceName
        self.workspaceRootUri = remoteRootUrl.standardizedFileURL
        self.remoteRootUrl = remoteRootUrl
        self.remoteFileDigests.removeAll()
    }

}

extension WorkspaceManager {

    struct HierarchicalFile {
        let url: URL
        let level: Int
        var children: [HierarchicalFile] = []
    }

    ///
    /// Fetch remote workspace files
    ///
    /// - Parameter skipsHidden     : Skip hidden files
    /// - Returns                   : Remote workspace files
    ///
    func fetchRemoteWorkspaceFiles(skipsHidden: Bool) -> [WorkspaceFile] {
        guard let enumerator = FileManager.default.enumerator(at: remoteRootUrl,
                includingPropertiesForKeys: WorkspaceFile.resourceValueKeys, options: skipsHidden ? .skipsHiddenFiles : []) else {
            fatalError()
        }

        var workspaceRootFile = HierarchicalFile(url: remoteRootUrl, level: .zero)
        enumerator.map({ $0 as! URL }).forEach({ parseFileHierarchy($0, &workspaceRootFile) })

        var flatList: [WorkspaceFile] = []
        convertFlatFileList(workspaceRootFile, &flatList)

        return flatList
    }

    ///
    /// Fetch local workspace files
    ///
    /// - Returns                   : Local workspace files
    ///
    func fetchLocalWorkspaceFiles() -> [DocumentUri] {
        guard let enumerator = FileManager.default.enumerator(at: localRootUrl, includingPropertiesForKeys: []) else {
            fatalError()
        }
        return enumerator.map({ ($0 as! URL).standardizedFileURL })
            .filter({ !$0.hasDirectoryPath })
            .sorted(by: { $0.path.localizedStandardCompare($1.path) == .orderedAscending })
    }

    private func parseFileHierarchy(_ target: URL, _ current: inout HierarchicalFile) {
        if let firstIndex = current.children.firstIndex(where: { target.hasPrefix($0.url) }) {
            parseFileHierarchy(target, &current.children[firstIndex])

        } else {
            let level = target.pathComponents.count - workspaceRootUri.pathComponents.count
            current.children.append(HierarchicalFile(url: target, level: level))
        }
    }

    private func convertFlatFileList(_ current: HierarchicalFile, _ flatList: inout [WorkspaceFile]) {
        flatList.append(WorkspaceFile(remoteUrl: current.url, level: current.level))
        current.children.sorted(by: filePriorityNaturalOrder).forEach({ convertFlatFileList($0, &flatList) })
    }

    private func filePriorityNaturalOrder(_ file1: HierarchicalFile, _ file2: HierarchicalFile) -> Bool {
        if file1.url.hasDirectoryPath == file2.url.hasDirectoryPath {
            return file1.url.path.localizedStandardCompare(file2.url.path) == .orderedAscending
        } else {
            return file2.url.hasDirectoryPath
        }
    }

}

extension WorkspaceManager {

    private enum Source {
        case remote
        case local

        func url(_ uri: DocumentUri, _ workspaceManager: WorkspaceManager) -> URL {
            let workspaceRootUri = workspaceManager.workspaceRootUri
            let relativePath = String(uri.path.replacingOccurrences(of: workspaceRootUri.path, with: "").dropFirst())
            switch self {
            case .remote:
                return workspaceManager.remoteRootUrl.appendingPathComponent(relativePath)
            case .local:
                return workspaceManager.localRootUrl.appendingPathComponent(relativePath)
            }
        }
    }

    func clone(uri: DocumentUri) throws {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }

        let remoteUrl = Source.remote.url(uri, self)
        let localUrl = Source.local.url(uri, self)

        do {
            let remoteData = try Data(contentsOf: remoteUrl)

            try FileManager.default.createDirectory(at: localUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            try remoteData.write(to: localUrl, options: .atomic)

            remoteFileDigests[uri] = SHA256.hash(data: remoteData)

        } catch CocoaError.fileReadNoSuchFile {
            throw WorkspaceError.fileNotFound
        }
    }

    func open(uri: DocumentUri) throws -> String {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }

        let localUrl = Source.local.url(uri, self)

        do {
            return try String(contentsOf: localUrl, encoding: .utf8)

        } catch CocoaError.fileReadNoSuchFile {
            throw WorkspaceError.fileNotFound

        } catch CocoaError.fileReadInapplicableStringEncoding {
            throw WorkspaceError.encodingFailure
        }
    }

    func save(uri: DocumentUri, text: String) throws {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }
        guard let data = text.data(using: .utf8) else {
            fatalError()
        }

        let localUrl = Source.local.url(uri, self)
        try FileManager.default.createDirectory(at: localUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: localUrl, options: .atomic)
    }

    func commit(uri: DocumentUri) throws {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }
        guard let remoteDigest = remoteFileDigests[uri] else {
            fatalError()
        }

        let localUrl = Source.local.url(uri, self)
        let remoteUrl = Source.remote.url(uri, self)

        if remoteDigest != SHA256.hash(data: try Data(contentsOf: remoteUrl)) {
            throw WorkspaceError.unintendedChanges
        }

        do {
            let localData = try Data(contentsOf: localUrl)
            try FileManager.default.createDirectory(at: remoteUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            try localData.write(to: remoteUrl, options: .atomic)

        } catch CocoaError.fileReadNoSuchFile {
            throw WorkspaceError.fileNotFound
        }
    }

    func exists(uri: DocumentUri) -> Bool {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }

        do {
            _ = try Data(contentsOf: Source.local.url(uri, self))
            return true
        } catch CocoaError.fileReadNoSuchFile {
            return false
        } catch {
            fatalError()
        }
    }

    func remove(uri: DocumentUri) throws {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }

        let localUrl = Source.local.url(uri, self)

        do {
            try FileManager.default.removeItem(at: localUrl)
        } catch CocoaError.fileNoSuchFile {
        }
    }

}
