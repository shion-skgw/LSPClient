//
//  RootView.swift
//  LSPClient
//
//  Created by Shion on 2021/02/11.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootView: UIView {

    override func draw(_ rect: CGRect) {
        let cgContext = UIGraphicsGetCurrentContext()!
        cgContext.setFillColor(UIColor.systemBackground.cgColor)
        cgContext.fill(frame)
        cgContext.setFillColor(UIColor.opaqueSeparator.cgColor)
        cgContext.fill(safeAreaLayoutGuide.layoutFrame)
    }

}
