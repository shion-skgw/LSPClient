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
        XCTAssert(CodeStyle.cache == nil)
        var aaa = CodeStyle.load()
        print(aaa)
        print(aaa.font.uiFont)
        print(CodeStyle.cache)
        aaa.font.uiFont = UIFont.monospacedDigitSystemFont(ofSize: 80.0, weight: .heavy)
        print(CodeStyle.cache)
        aaa.save()
        print(CodeStyle.cache)
        CodeStyle.remove()
        print(CodeStyle.cache)



        var a: NSMutableAttributedString? = NSMutableAttributedString(string: "\n1\n22\n333\n4444\n55555\n")
        let b = LineTable(content: a!)

		XCTAssertEqual((a!.string as NSString).substring(with: b.table[0]!), "\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[1]!), "1\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[2]!), "22\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[3]!), "333\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[4]!), "4444\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[5]!), "55555\n")

		let aa = b.range(for: TextRange(start: TextPosition(line: 3, character: 0), end: TextPosition(line: 3, character: 0)))
		print(aa!)
		print((a!.string as NSString).substring(with: aa!))

		b.replaceCharacters(in: NSMakeRange(a!.string.utf16.count, 0), with: "666666\n")
		XCTAssertEqual((a!.string as NSString).substring(with: b.table[6]!), "666666\n")
		print(a!)

		a = nil
        b.replaceCharacters(in: NSMakeRange(0, 0), with: "666666\n")
	}

	func testPerformanceExample() throws {
		self.measure {
		}
	}

}
