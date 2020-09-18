//
//  Functions.swift
//  LSPClientTests
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import XCTest
import Foundation
@testable import LSPClient

func dictionary(_ str: String) -> AnyValue {
    guard let firstIndex = str.firstIndex(of: "{"),
            let data = str[firstIndex..<str.endIndex].data(using: .utf8) else {
        fatalError()
    }
    print("Raw JSON value:\n\(str)\n")
    return try! JSONDecoder().decode(AnyValue.self, from: data)
}

