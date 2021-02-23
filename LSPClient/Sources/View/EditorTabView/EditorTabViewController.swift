//
//  EditorTabViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class EditorTabViewController: UIViewController {
    /// Tab container view
    private(set) weak var tabContainer: EditorTabView!
    /// Editor container view
    private(set) weak var editorContainer: UIView!

    /// Tab container view height
    private let tabViewHeight: CGFloat = 30
    /// Tab item width
    private let tabWidth: CGFloat = 140

    /// Active document URI
    private(set) var activeDocumentUri: DocumentUri?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load CodeStyle
        let codeStyle = CodeStyle.load()

        // Tab container view
        let tabContainer = EditorTabView()
        tabContainer.backgroundColor = codeStyle.tabAreaColor.uiColor
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        // Editor container view
        let editorContainer = UIView()
        editorContainer.backgroundColor = codeStyle.backgroundColor.uiColor
        view.addSubview(editorContainer)
        self.editorContainer = editorContainer

        // Notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Tab container view
        var tabContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        tabContainerFrame.size.height = tabViewHeight
        tabContainer.frame = tabContainerFrame

        // Editor container view
        var editorContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        editorContainerFrame.origin.y = tabContainerFrame.maxY
        editorContainerFrame.size.height -= editorContainerFrame.minY
        editorContainer.frame = editorContainerFrame

        // Editor view
        let editorViewFrame = CGRect(origin: .zero, size: editorContainerFrame.size)
        editorContainer.subviews.forEach({ $0.frame = editorViewFrame })
    }

    ///
    /// Add editor
    ///
    /// - Parameter editor: EditorViewController
    ///
    func add(editor: EditorViewController) {
        // Calc tab item frame
        var tabItemFrame = CGRect(origin: .zero, size: tabContainer.bounds.size)
        tabItemFrame.size.width = tabWidth
        tabItemFrame.size.height -= 1

        // Add tab item
        let tabItem = EditorTabItem(frame: tabItemFrame)
        tabItem.uri = editor.uri
        tabItem.set(codeStyle: CodeStyle.load())
        tabItem.addTarget(self, action: #selector(selectTab(_:)), for: .touchUpInside)
        tabItem.closeButton.uri = editor.uri
        tabItem.closeButton.addTarget(self, action: #selector(closeEditor(_:)), for: .touchUpInside)
        tabItem.fileName.text = editor.uri.lastPathComponent
        tabContainer.add(item: tabItem)

        // EditorViewController
        editor.view.frame = CGRect(origin: .zero, size: editorContainer.bounds.size)
        addChild(editor)
        editorContainer.addSubview(editor.view)
        editor.didMove(toParent: self)

        // Select tab
        showEditor(uri: editor.uri)
    }

    ///
    /// Show editor
    ///
    /// - Parameter uri: Document URI
    ///
    func showEditor(uri: DocumentUri) {
        tabContainer.tabItems.forEach({ $0.isActive = $0.uri == uri })
        children.compactMap({ $0 as? EditorViewController }).forEach({
            if $0.uri == uri {
                self.activeDocumentUri = uri
                $0.view.isHidden = false
                $0.view.becomeFirstResponder()
            } else {
                $0.view.isHidden = true
                $0.view.resignFirstResponder()
            }
        })
    }

    ///
    /// Tab select action
    ///
    /// - Parameter sender: Tab item
    ///
    @objc private func selectTab(_ sender: EditorTabItem) {
        showEditor(uri: sender.uri)
    }

    ///
    /// Close editor
    ///
    /// - Parameter sender: Tab close button
    ///
    @objc private func closeEditor(_ sender: EditorTabCloseButton) {
        guard let tabItem = tabContainer.tabItems.first(where: { $0.uri == sender.uri }),
                let controller = children.first(where: { ($0 as? EditorViewController)?.uri == sender.uri }) else {
            fatalError()
        }

        if let nextTabUri = nextTab(sender.uri)?.uri {
            showEditor(uri: nextTabUri)
        }

        // Remove EditorViewController
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()

        // Remove tab
        tabContainer.remove(item: tabItem)
    }

    ///
    /// Next tab item
    ///
    /// - Parameter uri: Document URI
    /// - Returns      : Next tab item
    ///
    private func nextTab(_ uri: DocumentUri) -> EditorTabItem? {
        let tabItems = tabContainer.tabItems
        if let index = tabItems.firstIndex(where: { $0.uri == uri }) {
            if index + 1 <= tabItems.count - 1 {
                return tabItems[index + 1]
            } else if 0 <= index - 1 {
                return tabItems[index - 1]
            }
        }
        return nil
    }

    ///
    /// a
    ///
    /// - Parameter uri: a
    /// - Returns      : a
    ///
    func hasEditor(uri: DocumentUri) -> Bool {
        return children.contains(where: { ($0 as? EditorViewController)?.uri == uri })
    }

    ///
    /// Refresh code style
    ///
    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        tabContainer.backgroundColor = codeStyle.tabAreaColor.uiColor
        tabContainer.tabItems.forEach({ $0.set(codeStyle: codeStyle) })
        editorContainer.backgroundColor = codeStyle.backgroundColor.uiColor
        children.compactMap({ $0 as? EditorViewController }).forEach({ $0.set(codeStyle: codeStyle) })
    }

}
