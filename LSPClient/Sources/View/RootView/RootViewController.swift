//
//  RootViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {
    /// SidebarMenuViewController
    private(set) weak var sidebarMenu: SidebarMenuViewController!
    /// WorkspaceViewController
    private(set) weak var workspace: WorkspaceViewController?
    /// SidebarMenuViewController
    private(set) weak var editor: EditorTabViewController!
    /// ConsoleViewController
    private(set) weak var console: ConsoleViewController?
    /// DiagnosticViewController
    private(set) weak var diagnostic: DiagnosticViewController?

    private let separatorWeight: CGFloat = 0.5
    private let sidebarMenuWidth: CGFloat = 40

    override func loadView() {
        self.view = RootView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sidebar menu
        let sidebarMenu = SidebarMenuViewController()
        add(child: sidebarMenu)
        self.sidebarMenu = sidebarMenu

        // Editor
        let editor = EditorTabViewController()
        add(child: editor)
        self.editor = editor

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(layoutSubviews), name: .keyboardWillChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(a), name: UIResponder.keyboardWillShowNotification, object: nil)

        // Connect language server
        let server = LanguageServer(name: "Test", host: "192.168.0.13", port: 2085, comment: "")
        MessageManager.shared.delegate = self
        MessageManager.shared.connection(server: server, method: TCPConnection.shared)

        // Init workspace
        let url = URL(string: "file://192.168.0.13/Users/shion/Documents/PyCharm/Test/")!
        WorkspaceManager.shared.initialize(workspaceName: "w", remoteRootUrl: url)

        let param = InitializeParams(rootUri: url)
        print(self.initialize(params: param))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }

    @objc func a(_ no: Notification) {
        let b = no.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let a = no.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        UIView.animate(withDuration: a as! TimeInterval, animations: {
            self.sidebarMenu.view.transform = CGAffineTransform(translationX: 0, y: -b.height)
        })
    }
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
        displayAreaFrame.origin.x += separatorWeight
        displayAreaFrame.origin.y += separatorWeight
        displayAreaFrame.size.width -= separatorWeight * 2
        displayAreaFrame.size.height -= separatorWeight * 2

        if let keyboardFrame = UIApplication.shared.keyboardView?.frame {
            displayAreaFrame.size.height -= view.bounds.height - keyboardFrame.minY
        }

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
        leftAreaFrame.size.height -= bottomAreaFrame.height == .zero ? .zero : bottomAreaFrame.height + separatorWeight

        if !sidebarMenu.view.isHidden {
            leftAreaFrame.size.width = sidebarMenuWidth
            sidebarMenu.view.frame = leftAreaFrame

        } else if let workspaceView = workspace?.view {
            leftAreaFrame.size.width = 300
            workspaceView.frame = leftAreaFrame
        }

        var editorFrame = displayAreaFrame
        editorFrame.origin.x = leftAreaFrame.maxX + separatorWeight
        editorFrame.origin.y = leftAreaFrame.origin.y
        editorFrame.size.width -= leftAreaFrame.width + separatorWeight
        editorFrame.size.height = leftAreaFrame.height
        editor.view.frame = editorFrame
    }
    /// Large file size alert threshold
    private let fileSizeThreshold: Int = 1024 * 512
    /// Open file size limit
    private let fileSizeLimit: Int = 1024 * 1024

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

        sidebarMenu.view.isHidden = true
    }

    func closeWorkspace() {
        guard let workspace = self.workspace else {
            fatalError()
        }

        sidebarMenu.view.isHidden = false
        workspace.closeView()
    }

    func showConsole() {
        if let console = self.console {
            add(child: console)

        } else {
            let console = ConsoleViewController()
            add(child: console)
            self.console = console
        }

        sidebarMenu.sidebarMenuView.consoleButton.isHidden = true
        sidebarMenu.sidebarMenuView.diagnosticButton.isHidden = true
    }

    func closeConsole() {
        guard let console = self.console else {
            fatalError()
        }

        sidebarMenu.sidebarMenuView.consoleButton.isHidden = false
        sidebarMenu.sidebarMenuView.diagnosticButton.isHidden = false
        console.closeView()
    }

    func showDiagnostic() {
        if let diagnostic = self.diagnostic {
            add(child: diagnostic)

        } else {
            let diagnostic = DiagnosticViewController()
            add(child: diagnostic)
            self.diagnostic = diagnostic
        }

        sidebarMenu.sidebarMenuView.consoleButton.isHidden = true
        sidebarMenu.sidebarMenuView.diagnosticButton.isHidden = true
    }

    func closeDiagnostic() {
        guard let diagnostic = self.diagnostic else {
            fatalError()
        }

        sidebarMenu.sidebarMenuView.consoleButton.isHidden = false
        sidebarMenu.sidebarMenuView.diagnosticButton.isHidden = false
        diagnostic.closeView()
    }

}


// MARK: - Workspace action

extension RootViewController {

    func willOpen(file: WorkspaceFile) {
        guard file.type == .file else {
            fatalError()
        }

        if WorkspaceManager.shared.exists(uri: file.uri) {
            openEditor(file)

        } else if file.size < fileSizeThreshold {
            openEditorWithClone(file)

        } else if file.size < fileSizeLimit {
            let alert = UIAlertController.largeFile(size: file.size, limit: fileSizeThreshold) {
                [weak self, file] _ in
                self?.openEditorWithClone(file)
            }
            present(alert, animated: true)

        } else {
            present(UIAlertController.unsupportedFile(uri: file.uri), animated: true)
        }
    }

    private func openEditorWithClone(_ file: WorkspaceFile) {
        do {
            try WorkspaceManager.shared.clone(uri: file.uri)
            _ = try WorkspaceManager.shared.open(uri: file.uri)
            openEditor(file)

        } catch WorkspaceError.fileNotFound {
            present(UIAlertController.fileNotFound(uri: file.uri), animated: true)

        } catch WorkspaceError.encodingFailure {
            try? WorkspaceManager.shared.remove(uri: file.uri)
            present(UIAlertController.unsupportedFile(uri: file.uri), animated: true)

        } catch {
            let title = "aaaa"
            let message = error.localizedDescription
            present(UIAlertController.anyAlert(title: title, message: message), animated: true)
        }
    }

    private func openEditor(_ file: WorkspaceFile) {
        if editor.hasEditor(uri: file.uri) {
            editor.showEditor(uri: file.uri)

        } else {
            let editorViewController = EditorViewController()
            editorViewController.uri = file.uri
            editor.add(editor: editorViewController)
        }

        closeWorkspace()
    }

}





extension RootViewController: MessageManagerDelegate {

    func connectionError(cause: Error) {
        print("\(#function)\n\(cause)\n")
    }
    func messageParseError(cause: Error, message: Message?) {
        print("\(#function)\n\(cause)\n\(message)\n")
    }
    func cancelRequest(params: CancelParams) {
        print("\(#function)\n\(params)\n")
    }
    func showMessage(params: ShowMessageParams) {
        print("\(#function)\n\(params)\n")
    }
    func showMessageRequest(id: RequestID, params: ShowMessageRequestParams) {
        print("\(#function)\n\(id)\n\(params)\n")
    }
    func logMessage(params: LogMessageParams) {
        print("\(#function)\n\(params)\n")
    }
    func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams) {
        print("\(#function)\n\(id)\n\(params)\n")
    }
    func publishDiagnostics(params: PublishDiagnosticsParams) {
        print("\(#function)\n\(params)\n")
    }

}


extension RootViewController: WorkspaceMessageDelegate {

    func initialize(id: RequestID, result: InitializeResult) {}
    func shutdown(id: RequestID, result: VoidValue?) {}
    func symbol(id: RequestID, result: [SymbolInformation]?) {}
    func executeCommand(id: RequestID, result: AnyValue?) {}
    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse) {}

}
