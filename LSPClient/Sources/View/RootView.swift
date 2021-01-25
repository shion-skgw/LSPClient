//
//  RootView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class RootView: UIView {

    override func draw(_ rect: CGRect) {
        let cgContext = UIGraphicsGetCurrentContext()!
        cgContext.setFillColor(UIColor.secondarySystemBackground.contrast(0.2).cgColor)
        cgContext.fill(safeAreaLayoutGuide.layoutFrame)
    }

}
