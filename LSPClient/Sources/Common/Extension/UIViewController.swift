//
//  UIViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/09/20.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.UIViewController

extension UIViewController {

    @inlinable func add(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

}
