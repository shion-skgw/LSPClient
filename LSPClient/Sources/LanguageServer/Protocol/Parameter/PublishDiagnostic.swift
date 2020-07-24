//
//  PublishDiagnostic.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - PublishDiagnostics Notification (textDocument/publishDiagnostics)

struct PublishDiagnosticsParams: NotificationParamsType {
	let uri: DocumentUri
	let version: Int?
	let diagnostics: [Diagnostic]
}
