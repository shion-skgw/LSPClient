//
//  RootViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    weak var viewContainer: UIView!
    weak var mainMenu: MainMenuViewController!
    weak var editor: MutableTabController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainMenu = MainMenuViewController()
        mainMenu.view.backgroundColor = .secondarySystemBackground
        add(child: mainMenu)
        self.mainMenu = mainMenu

        let editor = MutableTabController()
        add(child: editor)
        self.editor = editor

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(change), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var mainMenuFrame = view.safeAreaLayoutGuide.layoutFrame
        mainMenuFrame.size.height = 48.0
        mainMenu.view.frame = mainMenuFrame

        var editorFrame = view.safeAreaLayoutGuide.layoutFrame
        editorFrame.size.height -= mainMenuFrame.height + 5
        editorFrame.origin.y = mainMenuFrame.maxY + 5
        editor.view.frame = editorFrame
    }




    func didBecomeActive() {
        
    }

    func willResignActive() {

    }

    @objc private func change() {
//        guard let keyboardView = UIApplication.shared.keyboardView else {
//            return
//        }
    }

}
