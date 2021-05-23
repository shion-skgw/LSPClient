//
//  Notification.swift
//  LSPClient
//
//  Created by Shion on 2021/02/09.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

extension Notification {

    var userInfoValue: Any? {
        return userInfo?[name.rawValue + "_userInfoValue"]
    }

}

extension Notification.Name {
    static let keyboardWillChange = UIResponder.keyboardWillChangeFrameNotification
    static let didChangeCodeStyle = Notification.Name(rawValue: "didChangeCodeStyle")
    static let willOpenDocument = Notification.Name(rawValue: "willOpenDocument")
    static let didOpenDocument = Notification.Name(rawValue: "didOpenDocument")
    static let didReceiveDiagnostics = Notification.Name(rawValue: "didReceiveDiagnostics")
}
