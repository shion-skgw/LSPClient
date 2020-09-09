//
//  LSPClientTests.swift
//  LSPClientTests
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import XCTest
@testable import LSPClient

class LSPClientTests: XCTestCase {

	override func setUpWithError() throws {
	}

	override func tearDownWithError() throws {
	}

	func testExample() throws {
		let a = "\n1\n22\n333\n4444\n55555\n"
		let b = LineTableString(string: a)
		for i in 0 ... 10 {
			print(b.lineTable[i])
		}
		let str = b.string as NSString
		XCTAssertEqual(str.substring(with: b.lineTable[0]!), "\n")
		XCTAssertEqual(str.substring(with: b.lineTable[1]!), "1\n")
		XCTAssertEqual(str.substring(with: b.lineTable[2]!), "22\n")
		XCTAssertEqual(str.substring(with: b.lineTable[3]!), "333\n")
		XCTAssertEqual(str.substring(with: b.lineTable[4]!), "4444\n")
		XCTAssertEqual(str.substring(with: b.lineTable[5]!), "55555\n")

		let aa = b.range(for: TextRange(start: TextPosition(line: 3, character: 0), end: TextPosition(line: 3, character: 0)))
		print(aa!)
		print(str.substring(with: aa!))
	}

	func testPerformanceExample() throws {
		self.measure {
		}
	}

}
