//
//  RootViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    weak var mainMenu: MainMenuViewController!
    weak var editor: MutableTabController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainMenu = MainMenuViewController()
        add(child: mainMenu)
        self.mainMenu = mainMenu

        let editor = MutableTabController()
        add(child: editor)
        self.editor = editor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var mainMenuFrame = view.safeAreaLayoutGuide.layoutFrame
        mainMenuFrame.size.height = 48.0
        mainMenu.view.frame = mainMenuFrame

        var editorFrame = view.safeAreaLayoutGuide.layoutFrame
        editorFrame.size.height -= mainMenuFrame.height
        editorFrame.origin.y = mainMenuFrame.maxY
        editor.view.frame = editorFrame
    }

}
