//
//  AppDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessageManagerDelegate, ApplicationMessageDelegate {
    func shutdown(id: RequestID, result: Result<VoidValue?, ErrorResponse>) {
        print(#function)
        print(id)
        print(result)
    }

    func initialize(id: RequestID, result: Result<InitializeResult, ErrorResponse>) {
        print(#function)
        print(id)
        print(result)
    }


    func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams) {
        print(#function)
        print(id)
        print(params)
    }


    func showMessageRequest(id: RequestID, params: ShowMessageRequestParams) {
        print(#function)
        print(id)
        print(params)
    }


    func connectionError(cause: Error) {
        print(#function)
        print(cause)
    }

    func messageParseError(cause: Error, message: Message?) {
        print(#function)
        print(cause)
        print(message)
    }

    func cancelRequest(params: CancelParams) {
        print(#function)
        print(params)
    }

    func showMessage(params: ShowMessageParams) {
        print(#function)
        print(params)
    }

    func logMessage(params: LogMessageParams) {
        print(#function)
        print(params)
    }

    func publishDiagnostics(params: PublishDiagnosticsParams) {
        print(#function)
        print(params)
    }


    var window: UIWindow?
    weak var rootViewController: RootViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CodeStyle.remove()
        var a = CodeStyle.load()
        a.backgroundColor.uiColor = UIColor.brown
        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .medium)
        a.save()
//        a.backgroundColor.uiColor = UIColor.lightGray
//        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14.0, weight: .regular)
//        a.save()

        WorkspaceManager.shared.initialize(workspaceName: "w", rootUri: URL(string: "file:///Users/shion/Desktop/")!, host: "host", port: 1)
//        WorkspaceManager.shared.copy(documentUri: URL(string: "file:///Users/shion/Desktop/z/cc/1.jpg")!, source: .remote, destination: .original)

        let rootViewController = RootViewController()
//        let rootViewController = WorkspaceViewController()
        rootViewController.view.backgroundColor = UIColor.systemBackground
        self.rootViewController = rootViewController

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window

        MessageManager.shared.delegate = self
        MessageManager.shared.connection(server: LanguageServer(name: "a", host: "192.168.0.13", port: 12345, comment: ""), method: TCPConnection.shared)
        print(initialize(params: InitializeParams(rootUri: URL(string: "file:////Users/shion/Documents/PyCharm/Test")!)))
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

}
