//
//  NSRange.swift
//  LSPClient
//
//  Created by Shion on 2021/05/21.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

extension NSRange {

    static let notFound = NSRange(location: NSNotFound, length: .zero)

    @inlinable func inRange(_ target: NSRange) -> Bool {
        return lowerBound <= target.lowerBound && target.upperBound <= upperBound
    }

    init(_ textRange: TextRange, in text: String) {
        let lineRanges = text.lineRanges(start: textRange.start.line, end: textRange.end.line)
        guard let startRange = lineRanges.first?.range, let endRange = lineRanges.last?.range else {
            fatalError("\(textRange)")
        }
        let location = startRange.location + textRange.start.character
        let length = endRange.location + textRange.end.character - location
        self.init(location: location, length: length)
        print(textRange, self)
    }

}
