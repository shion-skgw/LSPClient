//
//  RootViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    let appearance = Appearance.self

    weak var mainMenu: MainMenuViewController!
    weak var editor: EditorTabViewController!
    weak var sidebarMenu: SidebarMenuViewController!
    weak var workspace: WorkspaceViewController?
    weak var console: ConsoleViewController?
    weak var diagnostic: DiagnosticViewController?

    override func loadView() {
        self.view = RootView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Main menu
        let mainMenu = MainMenuViewController()
        mainMenu.view.backgroundColor = appearance.mainMenuColor
        add(child: mainMenu)
        self.mainMenu = mainMenu

        // Sidebar menu
        let sidebarMenu = SidebarMenuViewController()
        sidebarMenu.view.backgroundColor = appearance.sidebarColor
        add(child: sidebarMenu)
        self.sidebarMenu = sidebarMenu

        // Editor
        let editor = EditorTabViewController()
        add(child: editor)
        self.editor = editor

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(layoutSubviews), name: .keyboardWillChange, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }

//    @objc func a(_ no: Notification) {
//        let b = no.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//        let a = no.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
//        UIView.animate(withDuration: a as! TimeInterval, animations: {
//            self.sidebarMenu.view.transform = CGAffineTransform(translationX: 0, y: -b.height)
//        })
//    }
//
//    @objc func q(_ no: Notification) {
//        let b = no.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//        let a = no.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
//        UIView.animate(withDuration: a as! TimeInterval, animations: {
//            self.sidebarMenu.view.transform = CGAffineTransform.identity
//        })
//    }

    @objc private func layoutSubviews() {
        var displayAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        displayAreaFrame.origin.x += appearance.viewMargin
        displayAreaFrame.origin.y += appearance.viewMargin
        displayAreaFrame.size.width -= appearance.viewMargin * 2
        displayAreaFrame.size.height -= appearance.viewMargin * 2

        if let keyboardFrame = UIApplication.shared.keyboardView?.frame {
            displayAreaFrame.size.height -= view.bounds.height - keyboardFrame.minY
        }

        var mainMenuFrame = displayAreaFrame
        mainMenuFrame.size.height = appearance.mainMenuHeight
        mainMenu.view.frame = mainMenuFrame

        var sideAreaFrame = displayAreaFrame
        sideAreaFrame.origin.y = mainMenuFrame.maxY + appearance.viewMargin
        sideAreaFrame.size.height -= mainMenuFrame.height + appearance.viewMargin

        if !sidebarMenu.view.isHidden {
            sideAreaFrame.size.width = appearance.sidebarWidth
            sidebarMenu.view.frame = sideAreaFrame

        } else if let workspaceView = workspace?.view {
            sideAreaFrame.size.width = 300
            workspaceView.frame = sideAreaFrame
        }

        var editorFrame = displayAreaFrame
        editorFrame.origin.x = sideAreaFrame.maxX + appearance.viewMargin
        editorFrame.origin.y = sideAreaFrame.origin.y
        editorFrame.size.width -= sideAreaFrame.width + appearance.viewMargin
        editorFrame.size.height = sideAreaFrame.height
        editor.view.frame = editorFrame
    }

}


// MARK: - Main menu action

extension RootViewController {
}


// MARK: - Sidebar action

extension RootViewController {

    func showWorkspace() {
        if let workspace = self.workspace {
            add(child: workspace)

        } else {
            let workspace = WorkspaceViewController()
            add(child: workspace)
            self.workspace = workspace
        }
    }

    func didCloseWorkspace() {
        self.sidebarMenu.view.isHidden = false
    }

}
