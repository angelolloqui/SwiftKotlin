//
//  ControlFlowTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 01/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class ControlFlowTransformerTests: XCTestCase {
    var transformer: ControlFlowTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = ControlFlowTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIfStatement() {
        let swift =
            "if number == 3 {}\n" +
            "if (number == 3) {}\n" +
            "if number == nil {}\n" +
            "if item is Movie {}\n" +
            "if !object.condition() {}\n"
        let kotlin =
            "if (number == 3) {}\n" +
            "if (number == 3) {}\n" +
            "if (number == nil) {}\n" +
            "if (item is Movie) {}\n" +
            "if (!object.condition()) {}\n"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    func testIfLetStatements() {
        let swift = "if let number = number {}"
        let kotlin = "if (number != null) {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
    func testIfLetStatementDifferentName() {
        let swift = "if let number = method() {}"
        let kotlin = "let number = method()\nif (number != null) {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    func testIfMultipleLetDeclaration() {
        let swift =
            "if let number = some.method(),\n" +
            "let param = object.itemAt(number) {}"
        let kotlin =
            "let number = some.method()\n" +
            "let param = object.itemAt(number)" +
            "if (number != null &&\nparam != null) {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
    func testIfNestedClousure() {
        let swift = "if numbers.flatMap({ $0 % 2}).count == 1 {}"
        let kotlin = "if (numbers.flatMap({ $0 % 2}).count == 1) {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
    func testForStatement() {
        let swift = "for current in someObjects {}"
        let kotlin = "for (current in someObjects) {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
    func testWhileStatement() {
        let swift = "while condition {}"
        let kotlin = "while (condition) {}"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    
    func testGuardStatement() {
        let swift =
            "guard number == 3 else { return }\n" +
            "guard value() >= 3 else { return }\n" +
            "guard condition else { return }\n" +
            "guard !condition else { return }\n"            
        let kotlin =
            "if (number != 3) { return }\n" +
            "if (value() < 3) { return }\n" +
            "if (!condition) { return }\n" +
            "if (condition) { return }\n"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    
    func testGuardLetStatements() {
        let swift = "guard let number = number else { return }"
        let kotlin = "if (number == null) { return }"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    func testGuardMultipleDeclaration() {
        let swift =
            "guard let result = some.method(),\n" +
            "let param = result.number(),\n" +
            "param > 1 else { return }"
        let kotlin =
            "let result = some.method()\n" +
            "let param = result.number()\n" +
            "if (result != null &&\nparam != null &&\nparam <= 1) { return }"
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

}
