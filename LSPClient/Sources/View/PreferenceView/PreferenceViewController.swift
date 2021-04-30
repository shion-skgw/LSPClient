//
//  PreferenceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/03/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class PreferenceViewController: UIViewController {
    /// Preference menu view
    private(set) weak var menu: PreferenceMenuView!
    /// Preference container view
    private(set) weak var container: UIScrollView!

    private(set) weak var workspaceSelect: WorkspaceSelectViewController?
    private(set) weak var workspaceConfig: WorkspaceConfigViewController?
    private(set) weak var languageServerConfig: LanguageServerConfigViewController?
    private(set) weak var appearance: AppearanceViewController?
    private(set) weak var codeStyle: CodeStyleViewController?

    private let menuWidth: CGFloat = 40
    private let separatorWeight: CGFloat = 0.5

    override func viewDidLoad() {
        self.view.backgroundColor = .opaqueSeparator

        // Preference menu view
        let menu = PreferenceMenuView(frame: .zero)
        menu.serverConfigButton.addAction(toggleMenu, for: .touchUpInside)
        menu.appearanceButton.addAction(toggleMenu, for: .touchUpInside)
        menu.codeStyleButton.addAction(toggleMenu, for: .touchUpInside)
        self.view.addSubview(menu)
        self.menu = menu

        // Preference container view
        let container = UIScrollView(frame: .zero)
        container.backgroundColor = .secondarySystemBackground
        self.view.addSubview(container)
        self.container = container
    }

    override func viewDidLayoutSubviews() {
        // Preference menu view
        var menuFrame = CGRect(origin: .zero, size: view.bounds.size)
        menuFrame.size.width = menuWidth
        menu.frame = menuFrame

        // Preference container view
        var containerFrame = CGRect(origin: .zero, size: view.bounds.size)
        containerFrame.origin.x = menuFrame.maxX
        containerFrame.origin.x += separatorWeight
        containerFrame.size.width -= containerFrame.minX
        container.frame = containerFrame

        // Preference view
        container.subviews.forEach({ $0.frame.size.width = containerFrame.width })
    }

    private func toggleMenu(_ action: UIAction) {
        guard let sender = action.sender as? UIButton else {
            fatalError()
        }

        if menu.isSelected(button: sender) {
            return
        }

        closeAll()

        if menu.serverConfigButton == sender {
            show(WorkspaceConfigViewController.self, &workspaceConfig)

        } else if menu.appearanceButton == sender {
            show(AppearanceViewController.self, &appearance)

        } else if menu.codeStyleButton == sender {
            show(CodeStyleViewController.self, &codeStyle)

        } else {
            fatalError()
        }

        menu.toggleHighlight(button: sender)
    }

    private func show<T: UIViewController>(_ type: T.Type, _ controller: inout T?) {
        if let controller = controller {
            addChild(controller)
            container.addSubview(controller.view)
            container.contentSize = controller.view.intrinsicContentSize
            controller.didMove(toParent: self)

        } else {
            let newController = type.init()
            addChild(newController)
            container.addSubview(newController.view)
            container.contentSize = newController.view.intrinsicContentSize
            newController.didMove(toParent: self)
            controller = newController
        }
    }

    private func closeAll() {
        children.forEach() {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
    }

}
