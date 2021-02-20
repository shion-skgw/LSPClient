//
//  RootView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/11.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootView: UIView {

    private let appearance = RootAppearance.self

    override func draw(_ rect: CGRect) {
        let cgContext = UIGraphicsGetCurrentContext()!
        cgContext.setFillColor(appearance.backgroundColor.cgColor)
        cgContext.fill(frame)
        cgContext.setFillColor(appearance.separatorColor.cgColor)
        cgContext.fill(safeAreaLayoutGuide.layoutFrame)
    }

}
