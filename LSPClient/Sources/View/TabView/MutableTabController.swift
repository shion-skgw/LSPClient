//
//  MutableTabController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit
import OSLog

final class MutableTabController: UIViewController {

    private(set) weak var tabContainer: TabView!
    private(set) weak var viewContainer: UIView!

    private(set) var tabHeight: CGFloat = UIFont.systemFontSize * 2

    private var currentTagNumber = 0
    private var nextTagNumber: Int {
        currentTagNumber += 1
        return currentTagNumber
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let codeStyle = CodeStyle.load()

        let tabContainer = TabView()
        tabContainer.backgroundColor = codeStyle.tabAreaColor.uiColor
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        let viewContainer = UIView()
        viewContainer.backgroundColor = codeStyle.backgroundColor.uiColor
        view.addSubview(viewContainer)
        self.viewContainer = viewContainer

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var tabContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        tabContainerFrame.size.height = tabHeight
        tabContainer.frame = tabContainerFrame

        var viewContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        viewContainerFrame.origin.y += tabHeight
        viewContainerFrame.size.height -= tabHeight
        viewContainer.frame = viewContainerFrame

        let editorViewFrame = CGRect(origin: .zero, size: viewContainer.bounds.size)
        viewContainer.subviews.forEach({ $0.frame = editorViewFrame })
    }

    @objc func selectTab(sender: TabItem) {
        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == sender.tag })
        viewContainer.subviews.forEach() {
            if $0.tag == sender.tag {
                $0.isHidden = false
                $0.becomeFirstResponder()
            } else {
                $0.isHidden = true
                $0.resignFirstResponder()
            }
        }
    }

    @objc func closeTab(sender: UIButton) {
        guard let tabItem = tabContainer.tabItems.filter({ $0.tag == sender.tag }).first,
                let controller = children.filter({ $0.view.tag == sender.tag }).first else {
            return
        }

        tabContainer.remove(item: tabItem)
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()

        if tabContainer.tabItems.filter({ $0.isActive }).isEmpty,
                let lastAddTab = tabContainer.tabItems.max(by: { $0.tag < $1.tag }) {
            selectTab(sender: lastAddTab)
        }
    }

    func addTab(title: String, viewController: EditorViewController) {
        let tagNumber = nextTagNumber

        // Add child controller
        viewController.view.tag = tagNumber
        viewController.view.frame = viewContainer.bounds
        addChild(viewController)
        viewContainer.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        // Add tab
        let a = CGRect(origin: .zero, size: CGSize(width: 100, height: 27))
        let tabItem = TabItem(frame: a)
        tabItem.set(title: title)
        tabItem.set(codeStyle: CodeStyle.load())
        tabItem.set(tagNumber: tagNumber)
        tabItem.addTarget(self, action: #selector(selectTab(sender:)), for: .touchUpInside)
        tabItem.closeButton.addTarget(self, action: #selector(closeTab(sender:)), for: .touchUpInside)
        tabContainer.add(item: tabItem)

        // Select tab
        selectTab(sender: tabItem)
    }

    @objc func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        tabContainer.backgroundColor = .secondarySystemBackground
        tabContainer.tabItems.forEach({ $0.set(codeStyle: codeStyle) })
        viewContainer.backgroundColor = codeStyle.backgroundColor.uiColor
    }

}
