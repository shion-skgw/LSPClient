//
//  Workspaces.swift
//  LSPClient
//
//  Created by Shion on 2020/08/05.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

struct Workspaces: ConfigType {
    static let configKey = "Workspaces"
    var workspaces: [Workspace]
    init() {
        self.workspaces = []
    }
}

struct Workspace: Codable {
    let name: String
    let serverId: ServerID
    let root: DocumentUri
    let comment: String
}
