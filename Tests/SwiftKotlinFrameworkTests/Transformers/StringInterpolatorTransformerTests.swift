//
//  StringInterpolatorTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/01/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import XCTest

class StringInterpolatorTransformerTests: XCTestCase {
    var transformer: StringInterpolatorTransformer!

    override func setUp() {
        super.setUp()
        transformer = StringInterpolatorTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleInterpolator() {
        let swift = "var string = \"name: \\(name)\""
        let kotlin = "var string = \"name: ${name}\""
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMultipleInterpolatorInSameString() {
        let swift = "var string = \"full name: \\(name) \\(lastName)\""
        let kotlin = "var string = \"full name: ${name} ${lastName}\""
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    
    func testOptionalInterpolator() {
        let swift = "var string = \"name: \\(name ?? lastName)\""
        let kotlin = "var string = \"name: ${name ?? lastName}\""
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testComplexExpressionInterpolator() {        
        let swift = "var string = \"name: \\(user?.name ?? (\"-\" + lastName))\""
        let kotlin = "var string = \"name: ${user?.name ?? (\"-\" + lastName)}\""
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
}
