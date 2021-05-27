//
//  AppDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CodeStyle.remove()
        var codeStyle = CodeStyle.load()
        codeStyle.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        codeStyle.fontColor.text.uiColor = UIColor.white
        codeStyle.fontColor.keyword.uiColor = UIColor(red: 0.8078, green: 0.1686, blue: 0.6392, alpha: 1.0)
        codeStyle.fontColor.function.uiColor = UIColor(red: 0.4353, green: 0.5961, blue: 0.8078, alpha: 1.0)
        codeStyle.fontColor.number.uiColor = UIColor(red: 1, green: 0.3176, blue: 0.3176, alpha: 1.0)
        codeStyle.fontColor.string.uiColor = UIColor(red: 1, green: 0.3176, blue: 0.3176, alpha: 1.0)
        codeStyle.fontColor.comment.uiColor = UIColor(red: 0.3451, green: 0.7294, blue: 0.2627, alpha: 1.0)
        codeStyle.fontColor.invisibles.uiColor = UIColor.white.withAlphaComponent(0.2)
        codeStyle.editorBaseColor.uiColor = UIColor(red: 0.1137, green: 0.1255, blue: 0.1686, alpha: 1.0)
        codeStyle.save()

        NotificationCenter.default.addObserver(self, selector: #selector(aaa), name: .willOpenDocument, object: nil)

        setupWindow()
        setupMenuItems()

        return true
    }

    @objc func aaa(_ notification: Notification) {
        guard let qwe = notification.userInfoValue as? DocumentUri else {
            fatalError()
        }
        print(qwe)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    private func setupWindow() {
        let window = UIWindow()
        window.rootViewController = RootViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    private func setupMenuItems() {
        if UIMenuController.shared.menuItems == nil {
            UIMenuController.shared.menuItems = []
        }

        UIMenuController.shared.menuItems?.append(contentsOf: [
            UIMenuItem(title: MenuStrings.hover, action: #selector(EditorViewController.invokeHover)),
        ])
    }

}
