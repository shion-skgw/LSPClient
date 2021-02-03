//
//  WorkspaceFile.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

struct WorkspaceFile {
    let uri: DocumentUri
    let level: Int
    let type: FileType
    let isHidden: Bool
}

extension WorkspaceFile {

    enum FileType {
        case directory
        case file
        case link
    }

}
