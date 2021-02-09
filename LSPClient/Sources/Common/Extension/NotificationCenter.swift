//
//  NotificationCenter.swift
//  LSPClient
//
//  Created by Shion on 2021/01/09.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

extension NotificationCenter {

    func post(name: NSNotification.Name, object: Any?, userInfoValue: Any? = nil) {
        if let userInfoValue = userInfoValue {
            let userInfo = [ name.rawValue + "_userInfoValue": userInfoValue ]
            self.post(name: name, object: object, userInfo: userInfo)
        } else {
            self.post(name: name, object: object, userInfo: nil)
        }
    }

}
