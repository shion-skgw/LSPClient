//
//  WorkspaceSymbol.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Workspace Symbols Request (workspace/symbol)

struct WorkspaceSymbolParams: RequestParamsType {
	let query: String
}
