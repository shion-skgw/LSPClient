//
//  WorkspaceError.swift
//  LSPClient
//
//  Created by Shion on 2021/02/20.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

enum WorkspaceError: Error {
    case fileExists
    case fileNotFound
    case encodingFailure
    case unintendedChanges
}
