//
//  UIButton.swift
//  LSPClient
//
//  Created by Shion on 2021/02/13.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIButton

extension UIButton {

    func addAction(_ handler: @escaping UIActionHandler, for controlEvents: UIControl.Event) {
        addAction(UIAction(handler: handler), for: controlEvents)
    }

}
