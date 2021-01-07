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
        tabContainer.backgroundColor = codeStyle.backgroundColor.uiColor.contrast(0.3)
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        let viewContainer = UIView()
        viewContainer.backgroundColor = codeStyle.backgroundColor.uiColor
        view.addSubview(viewContainer)
        self.viewContainer = viewContainer
        os_log("aaaaaaaaaaaaaaaaaaaaaaa")
        os_log(.debug, "aaaaaaaaaaaaa")
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
    }

    @objc func selectTab(sender: TabItem) {
        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == sender.tag })
        viewContainer.subviews.forEach({ $0.isHidden = $0.tag != sender.tag })
    }

    @objc func closeTab(sender: UIButton) {
        guard let tabItem = tabContainer.tabItems.filter({ $0.tag == sender.tag }).first,
                let child = children.filter({ $0.view.tag == sender.tag }).first else {
            return
        }

        tabContainer.remove(item: tabItem)
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

        if viewContainer.subviews.filter({ !$0.isHidden }).isEmpty,
                let lastAddView = viewContainer.subviews.max(by: { $0.tag < $1.tag }) {
            lastAddView.isHidden = false
            tabContainer.tabItems.forEach({ $0.isActive = $0.tag == lastAddView.tag })
        }
    }

    func addTab(title: String, viewController: EditorViewController) {
        let tagNumber = nextTagNumber

        // Add child, sub view
        viewController.view.tag = tagNumber
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

        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == tagNumber })
        viewContainer.subviews.forEach({ $0.isHidden = $0.tag != tagNumber })
    }

}
