//
//  WorkspaceEdit.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

struct WorkspaceEdit: ResultType {
    let changes: [String: [TextEdit]]? // TODO: changes?: { [uri: DocumentUri]: TextEdit[]; };
    let documentChanges: [DocumentChanges]?
}

extension WorkspaceEdit {
    enum DocumentChanges: Codable {
        case textDocumentEdit(TextDocumentEdit)
        case createFile(CreateFile)
        case renameFile(RenameFile)
        case deleteFile(DeleteFile)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let value = try? container.decode(TextDocumentEdit.self) {
                self = .textDocumentEdit(value)
            } else if let value = try? container.decode(CreateFile.self) {
                self = .createFile(value)
            } else if let value = try? container.decode(RenameFile.self) {
                self = .renameFile(value)
            } else {
                self = .deleteFile(try container.decode(DeleteFile.self))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .textDocumentEdit(let value):
                try container.encode(value)
            case .createFile(let value):
                try container.encode(value)
            case .renameFile(let value):
                try container.encode(value)
            case .deleteFile(let value):
                try container.encode(value)
            }
        }
    }
}
