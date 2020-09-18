//
//  Workspaces.swift
//  LSPClient
//
//  Created by Shion on 2020/08/05.
//  Copyright © 2020 Shion. All rights reserved.
//

struct Workspaces: ConfigType {
    static let configKey = "Workspaces"
    static var cache: Workspaces?
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
