//
//  UIImage.swift
//  LSPClient
//
//  Created by Shion on 2021/01/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

extension UIImage {

    static var gitIcon: UIImage {
        UIImage(named: "GitIcon")!
    }

    static var triangleRight: UIImage {
        UIImage(named: "TriangleRight")!
    }

    static var triangleDown: UIImage {
        UIImage(named: "TriangleDown")!
    }

    static func closeIcon(pointSize: CGFloat, weight: UIImage.SymbolWeight) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return UIImage(systemName: "xmark.circle.fill", withConfiguration: config)!
    }

}
