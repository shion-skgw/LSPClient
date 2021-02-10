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
    weak var sidebar: SidebarViewController!
    weak var editor: EditorTabViewController!
    weak var workspace: WorkspaceViewController?

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

        // Sidebar
        let sidebar = SidebarViewController()
        sidebar.view.backgroundColor = appearance.sidebarColor
        sidebar.rootController = self
        add(child: sidebar)
        self.sidebar = sidebar

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

        if let workspaceView = workspace?.view {
            sideAreaFrame.size.width = 300
            workspaceView.frame = sideAreaFrame
        } else {
            sideAreaFrame.size.width = appearance.sidebarWidth
            sidebar.view.frame = sideAreaFrame
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
        let workspace = WorkspaceViewController()
        add(child: workspace)
        print(workspace.view.frame)
        self.workspace = workspace
        self.sidebar.view.isHidden = true
    }

}
