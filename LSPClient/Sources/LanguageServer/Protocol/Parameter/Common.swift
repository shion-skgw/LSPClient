//
//  Common.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Cancellation Support ($/cancelRequest)

struct CancelParams: NotificationParamsType {
    let id: RequestID
}
