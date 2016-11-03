//
//  KeywordReplacementTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class KeywordReplacementTransformerTests: XCTestCase {
    var transformer: KeywordReplacementTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = KeywordReplacementTransformer()
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
    
    
    func testFuncDeclarations() {
        let swift =
            "func test(){}\n" +
            "private func funcTest(){}\n" +
            "override func afunc (){}\n"
        
        let kotlin =
            "fun test(){}\n" +
            "private fun funcTest(){}\n" +
            "override fun afunc (){}\n"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    func testSelfReference() {
        let swift =
            "self.method()\n" +
            "self.property\n" +
            "var strongSelf = self\n" +
            "var selfA = a_self\n"
        
        let kotlin =
            "this.method()\n" +
            "this.property\n" +
            "var strongSelf = this\n" +
            "var selfA = a_self\n"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    func testAnonymousClousureParameter() {
        let swift = "numbers.map { 3 * $0.value }"
        let kotlin = "numbers.map { 3 * it.value }"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    func testProtocolInterface() {
        let swift =
            "protocol Nameable {}" +
            "public protocol protocolNameable_protocol {}"
        let kotlin =
            "interface Nameable {}" +
            "public interface protocolNameable_protocol {}"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
    func testNilConstant() {
        let swift = "var variable: Int? = nil"
        let kotlin = "var variable: Int? = null"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    func testCoalescingOperator() {
        let swift = "var nextPage = (stateValue.lastPage ?? 0) + 1"
        let kotlin = "var nextPage = (stateValue.lastPage ?: 0) + 1"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    
    func testClosedRangeOperator() {
        let swift = "for i in 1...3 {}"
        let kotlin = "for i in 1..3 {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
}
