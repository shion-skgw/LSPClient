//
//  WorkspaceManager.swift
//  LSPClient
//
//  Created by Shion on 2021/01/23.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

final class WorkspaceManager {

    static let shared: WorkspaceManager = WorkspaceManager()

    private(set) var workspaceName: String

    private(set) var workspaceUrl: URL

    private(set) var remoteWorkspaceUrl: URL

    var localWorkspaceUrl: URL {
        guard let applicationSupport = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first,
                let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError()
        }
        var url = URL(fileURLWithPath: applicationSupport, isDirectory: true)
        url.appendPathComponent(bundleIdentifier, isDirectory: true)
        url.appendPathComponent(workspaceName, isDirectory: true)
        return url
    }

    var originalWorkspaceUrl: URL {
        localWorkspaceUrl.appendingPathComponent("orig", isDirectory: true)
    }

    var editWorkspaceUrl: URL {
        localWorkspaceUrl.appendingPathComponent("edit", isDirectory: true)
    }

    private(set) var files: [DocumentUri: Property]

    var fileList: [FileProperty] {
        return files.map({ FileProperty(documentUri: $0.key, property: $0.value) })
            .sorted(by: { $0.documentUri.absoluteString.localizedStandardCompare($1.documentUri.absoluteString) == .orderedAscending })
    }

    private init() {
        self.workspaceName = ""
        self.workspaceUrl = URL(string: "file:///")!
        self.remoteWorkspaceUrl = URL(string: "file:///")!
        self.files = [:]
    }

    func initialize(workspaceName: String, workspaceUrl: URL, host: String, port: Int) {
        guard let remoteWorkspaceUrl = URL(string: "file://\(host):\(port)\(workspaceUrl.path)/") else {
            fatalError()
        }
        self.workspaceName = workspaceName
        self.workspaceUrl = workspaceUrl
        self.remoteWorkspaceUrl = remoteWorkspaceUrl
        self.files.removeAll()
        self.refreshSourceList()
    }

    func refreshSourceList() {
        let includingKeys: [URLResourceKey] = [
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .isAliasFileKey,
            .isHiddenKey,
            .fileSizeKey
        ]
        guard let enumerator = FileManager.default.enumerator(at: remoteWorkspaceUrl, includingPropertiesForKeys: includingKeys) else {
            fatalError()
        }
        for element in enumerator {
            guard let url = element as? NSURL,
                    let documentUri = documentUri(url),
                    let properties = try? url.resourceValues(forKeys: includingKeys),
                    let isDirectory = (properties[.isDirectoryKey] as? NSNumber)?.boolValue,
                    let isSymbolicLink = (properties[.isSymbolicLinkKey] as? NSNumber)?.boolValue,
                    let isAliasFile = (properties[.isAliasFileKey] as? NSNumber)?.boolValue,
                    let isHidden = (properties[.isHiddenKey] as? NSNumber)?.boolValue else {
                continue
            }
            let relativeLevel = documentUri.pathComponents.count - workspaceUrl.pathComponents.count
            let fileSize = (properties[.fileSizeKey] as? NSNumber)?.intValue ?? 0
            let source = Property(url as URL, relativeLevel, isDirectory, isSymbolicLink || isAliasFile, isHidden, fileSize)
            files[documentUri] = source
        }
    }

    func copy(documentUri: DocumentUri, source: Source, destination: Source) {
        guard source != destination, files[documentUri]?.isDirectory == false else {
            fatalError()
        }

        // Source file URL
        var sourceUrl: URL
        switch source {
        case .remote:   sourceUrl = remoteWorkspaceUrl
        case .original: sourceUrl = originalWorkspaceUrl
        case .edit:     sourceUrl = editWorkspaceUrl
        }
        sourceUrl.appendPathComponent(relativePath(documentUri), isDirectory: false)

        // Destination file URL
        var destinationUrl: URL
        switch destination {
        case .remote:   destinationUrl = remoteWorkspaceUrl
        case .original: destinationUrl = originalWorkspaceUrl
        case .edit:     destinationUrl = editWorkspaceUrl
        }
        destinationUrl.appendPathComponent(relativePath(documentUri), isDirectory: false)
    }

    private func documentUri(_ url: NSURL) -> DocumentUri? {
        if let host = url.host, let absoluteString = url.absoluteString {
            return DocumentUri(string: absoluteString.replacingOccurrences(of: host, with: ""))
        }
        return url as DocumentUri
    }

    private func relativePath(_ documentUri: DocumentUri) -> String {
        return documentUri.absoluteString.replacingOccurrences(of: workspaceUrl.absoluteString, with: "")
    }

}

extension WorkspaceManager {

    struct FileProperty {
        let documentUri: DocumentUri
        let property: Property
    }

    struct Property {
        let remoteUrl: URL
        let relativeLevel: Int
        let isDirectory: Bool
        let isSymbolicLink: Bool
        let isHidden: Bool
        let fileSize: Int

        fileprivate init(_ remoteUrl: URL, _ relativeLevel: Int, _ isDirectory: Bool, _ isSymbolicLink: Bool, _ isHidden: Bool, _ fileSize: Int) {
            self.remoteUrl = remoteUrl
            self.relativeLevel = relativeLevel
            self.isDirectory = isDirectory
            self.isSymbolicLink = isSymbolicLink
            self.isHidden = isHidden
            self.fileSize = fileSize
        }
    }

    enum Source {
        case remote
        case original
        case edit
    }

}
