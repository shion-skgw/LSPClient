//
//  RootViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    private let appearance = Appearance.self

    private weak var mainMenu: MainMenuViewController!
    private weak var editor: EditorTabViewController!
    private weak var sidebarMenu: SidebarMenuViewController!
    private weak var workspace: WorkspaceViewController?
    private weak var console: ConsoleViewController?
    private weak var diagnostic: DiagnosticViewController?

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

        var bottomAreaFrame = displayAreaFrame
        bottomAreaFrame.origin.y += displayAreaFrame.height - 10
        bottomAreaFrame.size.height = 10

        if console?.view.isHidden == false {
            console?.view.frame = bottomAreaFrame

        } else if diagnostic?.view.isHidden == false {
            diagnostic?.view.frame = bottomAreaFrame

        } else {
            bottomAreaFrame.origin.y = displayAreaFrame.maxY
            bottomAreaFrame.size.height = .zero
        }

        var leftAreaFrame = displayAreaFrame
        leftAreaFrame.origin.y = mainMenuFrame.maxY + appearance.viewMargin
        leftAreaFrame.size.height -= mainMenuFrame.height + appearance.viewMargin
        leftAreaFrame.size.height -= bottomAreaFrame.height == .zero ? .zero : bottomAreaFrame.height + appearance.viewMargin

        if !sidebarMenu.view.isHidden {
            leftAreaFrame.size.width = appearance.sidebarWidth
            sidebarMenu.view.frame = leftAreaFrame

        } else if let workspaceView = workspace?.view {
            leftAreaFrame.size.width = 300
            workspaceView.frame = leftAreaFrame
        }

        var editorFrame = displayAreaFrame
        editorFrame.origin.x = leftAreaFrame.maxX + appearance.viewMargin
        editorFrame.origin.y = leftAreaFrame.origin.y
        editorFrame.size.width -= leftAreaFrame.width + appearance.viewMargin
        editorFrame.size.height = leftAreaFrame.height
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

    func showConsole() {
        if let console = self.console {
            add(child: console)

        } else {
            let console = ConsoleViewController()
            console.view.backgroundColor = .brown
            add(child: console)
            self.console = console
        }
    }

    func showDiagnostic() {
        if let diagnostic = self.diagnostic {
            add(child: diagnostic)

        } else {
            let diagnostic = DiagnosticViewController()
            diagnostic.view.backgroundColor = .gray
            add(child: diagnostic)
            self.diagnostic = diagnostic
        }
    }

    func didCloseWorkspace() {
        sidebarMenu.didCloseWorkspace()
    }

    func didCloseConsole() {
        sidebarMenu.didCloseConsole()
    }

    func didCloseDiagnostic() {
        sidebarMenu.didCloseDiagnostic()
    }

}
