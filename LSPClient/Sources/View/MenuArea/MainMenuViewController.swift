//
//  MainMenuViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class MainMenuViewController: UIViewController {

    private(set) weak var leftMenu: MainMenuView!
    private(set) weak var rightMenu: MainMenuView!
    private(set) weak var add: UIButton!

    override func loadView() {
        let borderView = BorderView()
        borderView.backgroundColor = CommonView.background
        borderView.borderPosition = [.bottom]
        borderView.borderWidth = 0.5
        borderView.borderColor = CommonView.backgroundBorder.cgColor
        self.view = borderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftMenu = MainMenuView(frame: .zero)
        leftMenu.alignment = .left
        let add = UIButton(type: .contactAdd)
        add.addTarget(self, action: #selector(add(sender:)), for: .touchUpInside)
        leftMenu.addSubview(add)
        self.add = add
        leftMenu.addSubview(UIButton(type: .contactAdd))
        leftMenu.addSubview(UIButton(type: .contactAdd))
        leftMenu.addSubview(UIButton(type: .contactAdd))
        leftMenu.addSubview(UIButton(type: .contactAdd))
        leftMenu.addSubview(UIButton(type: .contactAdd))
//        leftMenu.backgroundColor = .gray
        view.addSubview(leftMenu)
        self.leftMenu = leftMenu

        let rightMenu = MainMenuView(frame: .zero)
        rightMenu.alignment = .right
        rightMenu.addSubview(UIButton(type: .contactAdd))
        rightMenu.addSubview(UIButton(type: .contactAdd))
        rightMenu.addSubview(UIButton(type: .contactAdd))
//        rightMenu.backgroundColor = .brown
        view.addSubview(rightMenu)
        self.rightMenu = rightMenu
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var leftMenuFrame = CGRect(origin: .zero, size: view.bounds.size)
        leftMenuFrame.size.width = leftMenuFrame.width / 2.0
        leftMenu.frame = leftMenuFrame

        var rightMenuFrame = CGRect(origin: .zero, size: view.bounds.size)
        rightMenuFrame.origin.x = leftMenuFrame.width
        rightMenuFrame.size.width = rightMenuFrame.width - rightMenuFrame.origin.x
        rightMenu.frame = rightMenuFrame
    }

    @objc func add(sender: UIButton) {
        let aaa = parent as! RootViewController
        let a = EditorViewController()
        var aa = CGRect(origin: .zero, size: aaa.editor.viewContainer.bounds.size)
        a.view.frame = aa
        aaa.editor.addTab(title: "aaaaaaaaa", viewController: a)
    }

}
