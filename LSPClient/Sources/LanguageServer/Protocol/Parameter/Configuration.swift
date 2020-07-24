//
//  Configuration.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - DidChangeConfiguration Notification (workspace/didChangeConfiguration)

struct DidChangeConfigurationParams: NotificationParamsType {
	let settings: AnyValue
}
