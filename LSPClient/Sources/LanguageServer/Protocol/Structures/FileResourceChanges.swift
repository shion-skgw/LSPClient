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
	let kind: ResourceChangeKind = .create
	let uri: DocumentUri
	let options: CreateFileOptions?
}

struct RenameFileOptions: Codable {
	let overwrite: Bool?
	let ignoreIfExists: Bool?
}

struct RenameFile: Codable {
	let kind: ResourceChangeKind = .rename
	let oldUri: DocumentUri
	let newUri: DocumentUri
	let options: RenameFileOptions?
}

struct DeleteFileOptions: Codable {
	let recursive: Bool?
	let ignoreIfNotExists: Bool?
}

struct DeleteFile: Codable {
	let kind: ResourceChangeKind = .delete
	let uri: DocumentUri
	let options: DeleteFileOptions?
}

enum ResourceChangeKind: String, Codable {
	case create = "create"
	case rename = "rename"
	case delete = "delete"
}
