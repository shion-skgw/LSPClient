//
//  LanguageServers.swift
//  LSPClient
//
//  Created by Shion on 2020/08/05.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

struct LanguageServers: ConfigType {
    static let configKey = "LanguageServers"
    var servers: [ServerID: LanguageServer]
    init() {
        self.servers = [:]
    }
}

struct LanguageServer: Codable {
    let name: String
    let host: String
    let port: Int
    let comment: String
}

struct ServerID: Codable, Hashable {
    let id: String
    init() {
        self.id = String(UInt64(Date().timeIntervalSince1970))
    }
}
