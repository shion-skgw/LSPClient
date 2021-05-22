//
//  ConsoleViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/13.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class ConsoleViewController: UIViewController {

    func closeView() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}
