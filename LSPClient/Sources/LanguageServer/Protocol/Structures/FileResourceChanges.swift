//
//  FileResourceChanges.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct CreateFileOptions: Codable {
    let overwrite: Bool?
    let ignoreIfExists: Bool?
}

struct CreateFile: Codable {
    let kind: ResourceChangeKind
    let uri: DocumentUri
    let options: CreateFileOptions?

    init(uri: DocumentUri, options: CreateFileOptions?) {
        self.kind = .create
        self.uri = uri
        self.options = options
    }
}

struct RenameFileOptions: Codable {
    let overwrite: Bool?
    let ignoreIfExists: Bool?
}

struct RenameFile: Codable {
    let kind: ResourceChangeKind
    let oldUri: DocumentUri
    let newUri: DocumentUri
    let options: RenameFileOptions?

    init(oldUri: DocumentUri, newUri: DocumentUri, options: RenameFileOptions?) {
        self.kind = .rename
        self.oldUri = oldUri
        self.newUri = newUri
        self.options = options
    }
}

struct DeleteFileOptions: Codable {
    let recursive: Bool?
    let ignoreIfNotExists: Bool?
}

struct DeleteFile: Codable {
    let kind: ResourceChangeKind
    let uri: DocumentUri
    let options: DeleteFileOptions?

    init(uri: DocumentUri, options: DeleteFileOptions?) {
        self.kind = .delete
        self.uri = uri
        self.options = options
    }
}

enum ResourceChangeKind: String, Codable {
    case create = "create"
    case rename = "rename"
    case delete = "delete"
}
