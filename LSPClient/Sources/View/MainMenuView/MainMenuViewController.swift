//
//  MainMenuViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class MainMenuViewController: UIViewController {

    override func loadView() {
        let mainMenuView = MainMenuView(frame: .zero)
        mainMenuView.backgroundColor = MainMenuAppearance.viewColor
        self.view = mainMenuView
    }

}
