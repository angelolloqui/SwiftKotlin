//
//  KeywordReplacementTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class KeywordReplacementTransformerTests: XCTestCase {
    var transformer: KeywordResplacementTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = KeywordResplacementTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLetConstants() {
        let swift =
            "let variable = \"string\"\n" +
            "let letVariable = \"string\"\n" +
            "let variableLet = \"string\"\n"
        
        let kotlin =
            "val variable = \"string\"\n" +
            "val letVariable = \"string\"\n" +
            "val variableLet = \"string\"\n"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

}
