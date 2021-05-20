//
//  NSRange.swift
//  LSPClient
//
//  Created by Shion on 2021/05/21.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

extension NSRange {

    static let zero = NSRange()

    @inlinable func isInRange(_ target: NSRange) -> Bool {
        return target.lowerBound <= lowerBound && upperBound <= target.upperBound
    }

}
