//
//  UIApplication.swift
//  LSPClient
//
//  Created by Shion on 2021/01/15.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIApplication

extension UIApplication {

    var keyboardView: UIView? {
        for window in windows.filter({ NSStringFromClass($0.classForCoder) == "UIRemoteKeyboardWindow" }) {
            for view in window.subviews {
                if let inputSetHostView = getInputSetHostView(view) {
                    return inputSetHostView
                }
            }
        }
        return nil
    }

    private func getInputSetHostView(_ view: UIView) -> UIView? {
        if NSStringFromClass(view.classForCoder) == "UIInputSetHostView" {
            return view
        }
        for subview in view.subviews {
            return getInputSetHostView(subview)
        }
        return nil
    }

}
