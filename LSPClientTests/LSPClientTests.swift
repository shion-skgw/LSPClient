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
		var a: NSMutableAttributedString? = NSMutableAttributedString(string: "\n1\n22\n333\n4444\n55555\n")
		let b = LineTable(string: a!)

		XCTAssertEqual((a!.string as NSString).substring(with: b.table[0]!), "\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[1]!), "1\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[2]!), "22\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[3]!), "333\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[4]!), "4444\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[5]!), "55555\n")

		let aa = b.range(for: TextRange(start: TextPosition(line: 3, character: 0), end: TextPosition(line: 3, character: 0)))
		print(aa!)
		print((a!.string as NSString).substring(with: aa!))

		a!.replaceCharacters(in: NSMakeRange(a!.string.utf16.count, 0), with: "666666\n")
		b.update(for: NSMakeRange(a!.string.utf16.count, 0))
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[6]!), "666666\n")
		print(a!)

		a = nil
		b.update(for: NSMakeRange(0, 10))
	}

	func testPerformanceExample() throws {
		self.measure {
		}
	}

}
