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
        guard let startNSRange = lineRanges.first?.range,
                let endNSRange = lineRanges.last?.range,
                let startRange = Range(startNSRange, in: text),
                let endRange = Range(endNSRange, in: text),
                let startIndex = text.utf8.index(startRange.lowerBound, offsetBy: textRange.start.character, limitedBy: text.endIndex),
                let endIndex = text.utf8.index(endRange.lowerBound, offsetBy: textRange.end.character, limitedBy: text.endIndex) else {
            self = .notFound
            print(textRange, self)
            return
//            fatalError("\(textRange)")
        }
        self.init(startIndex..<endIndex, in: text)
        print(textRange, self)
    }

}
