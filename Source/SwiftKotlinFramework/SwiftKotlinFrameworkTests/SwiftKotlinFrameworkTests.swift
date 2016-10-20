//
//  SwiftKotlinFrameworkTests.swift
//  SwiftKotlinFrameworkTests
//
//  Created by Angel Garcia on 12/09/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class SwiftKotlinFrameworkTests: XCTestCase {
    var swiftKotlin: SwiftKotlin!
    
    override func setUp() {
        super.setUp()
        swiftKotlin = SwiftKotlin()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatesTransformers() {
        XCTAssertTrue(swiftKotlin.transformers.count > 0)
    }
    
    
}
