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
        var a = CodeStyle.load()
        a.backgroundColor.uiColor = UIColor.lightGray
        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14.0, weight: .regular)
        a.fontColor.uiColor = UIColor.darkGray
        a.invisiblesFontColor.uiColor = UIColor.yellow
        a.save()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let root = ViewController()
        let sub = EditorViewController()
        root.view.addSubview(sub.view)
        root.addChild(sub)
        sub.didMove(toParent: root)
        window.rootViewController = root
        window.backgroundColor = .systemFill
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}

final class ViewController: UIViewController {
}
