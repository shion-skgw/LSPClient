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
    /// - Parameter remoteRootUrl   : Language server workspace root URL
    ///
    func initialize(workspaceName: String, remoteRootUrl: URL) {
        self.workspaceName = workspaceName
        self.workspaceRootUri = remoteRootUrl.standardizedFileURL
        self.remoteRootUrl = remoteRootUrl
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

    enum WorkspaceError: Error {
        case fileNotFound
        case fileExists
        case any(Error)
    }

    enum Source {
        case remote
        case local

        func url(_ uri: DocumentUri, _ workspaceManager: WorkspaceManager) -> URL {
            let workspaceRootUri = workspaceManager.workspaceRootUri
            let relativePath = uri.absoluteString.replacingOccurrences(of: workspaceRootUri.absoluteString, with: "")
            switch self {
            case .remote:
                return workspaceManager.remoteRootUrl.appendingPathComponent(relativePath)
            case .local:
                return workspaceManager.localRootUrl.appendingPathComponent(relativePath)
            }
        }
    }

    func copy(uri: DocumentUri, from source: Source, to destination: Source, isForced: Bool = false) -> Result<Data, WorkspaceError> {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }

        let sourceUrl = source.url(uri, self)
        let destinationUrl = destination.url(uri, self)

        do {
            let sourceData = try Data(contentsOf: sourceUrl)

            if !isForced, let destinationData = try? Data(contentsOf: destinationUrl) {
                if SHA256.hash(data: sourceData) == SHA256.hash(data: destinationData) {
                    return .success(destinationData)
                } else {
                    return .failure(.fileExists)
                }
            }

            try FileManager.default.createDirectory(at: destinationUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            try sourceData.write(to: destinationUrl, options: .atomic)
            return .success(sourceData)

        } catch CocoaError.fileReadNoSuchFile {
            return .failure(.fileNotFound)

        } catch {
            return .failure(.any(error))
        }
    }

    func remove(uri: DocumentUri, source: Source) -> Result<Void, WorkspaceError> {
        guard !uri.hasDirectoryPath, uri.hasPrefix(workspaceRootUri) else {
            fatalError()
        }

        do {
            try FileManager.default.removeItem(at: source.url(uri, self))
            return .success(())

        } catch CocoaError.fileNoSuchFile {
            return .failure(.fileNotFound)

        } catch {
            return .failure(.any(error))
        }
    }

}
