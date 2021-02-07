//
//  NotificationCenter.swift
//  LSPClient
//
//  Created by Shion on 2021/01/09.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didChangeCodeStyle = Notification.Name(rawValue: "didChangeCodeStyle")
    static let willOpenDocument = Notification.Name(rawValue: "willOpenDocument")
    static let didOpenDocument = Notification.Name(rawValue: "didOpenDocument")
}
