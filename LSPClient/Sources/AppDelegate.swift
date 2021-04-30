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
    weak var rootViewController: RootViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CodeStyle.remove()
        var codeStyle = CodeStyle.load()
        codeStyle.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        codeStyle.fontColor.text.uiColor = UIColor.black
        codeStyle.fontColor.keyword.uiColor = UIColor.red
        codeStyle.fontColor.function.uiColor = UIColor.blue
        codeStyle.fontColor.number.uiColor = UIColor.blue
        codeStyle.fontColor.string.uiColor = UIColor.purple
        codeStyle.fontColor.comment.uiColor = UIColor.green
        codeStyle.fontColor.invisibles.uiColor = UIColor.gray
        codeStyle.backgroundColor.uiColor = UIColor.brown
        codeStyle.save()

        let rootViewController = RootViewController()
        self.rootViewController = rootViewController

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(aaa), name: .willOpenDocument, object: nil)

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

}
