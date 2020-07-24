//
//  ApplyWorkspaceEdit.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Applies a WorkspaceEdit (workspace/applyEdit)

struct ApplyWorkspaceEditParams: RequestParamsType {
	let label: String?
	let edit: WorkspaceEdit
}

struct ApplyWorkspaceEditResponse: ResultType {
	let applied: Bool
	let failureReason: String?
}
