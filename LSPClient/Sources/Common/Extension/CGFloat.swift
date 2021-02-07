//
//  CGFloat.swift
//  LSPClient
//
//  Created by Shion on 2021/02/07.
//  Copyright © 2021 Shion. All rights reserved.
//

import CoreGraphics

extension CGFloat {

    @inlinable func centeringPoint(_ target: CGFloat) -> CGFloat {
        return (self - target) / 2.0
    }

}
