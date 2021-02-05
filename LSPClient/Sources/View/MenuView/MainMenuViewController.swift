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
    private(set) weak var change: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftMenu = MainMenuView(frame: .zero)
        leftMenu.alignment = .left
        let add = UIButton(type: .contactAdd)
        add.addTarget(self, action: #selector(add(sender:)), for: .touchUpInside)
        leftMenu.addSubview(add)
        self.add = add

        let change = UIButton(type: .contactAdd)
        change.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
        leftMenu.addSubview(change)
        self.change = change

        let git = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        git.setImage(UIImage.gitIcon, for: .normal)
        leftMenu.addSubview(git)
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
        a.view.frame = CGRect(origin: .zero, size: aaa.editor.viewContainer.bounds.size)
        aaa.editor.addTab(title: "ADEnkjargalnkergaSDF", viewController: a)
    }

    @objc func changeColor() {
        var a = CodeStyle.load()
        a.backgroundColor.uiColor = UIColor.black
        a.save()
        NotificationCenter.default.post(name: .didChangeCodeStyle, object: nil)
    }

}
