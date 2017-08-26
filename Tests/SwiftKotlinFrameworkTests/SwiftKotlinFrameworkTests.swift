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
    
    func testUsesCustomTransformers() {
        class CustomTransformer: Transformer {
            var translated = false
            func transform(formatter: Formatter, options: TransformOptions? = nil) throws {
                translated = true
                formatter.insertToken(.identifier(" translated"), at: formatter.tokens.count)
            }
        }
        let transformer = CustomTransformer()
        swiftKotlin = SwiftKotlin(transformers: [transformer])
        let translate = try? swiftKotlin.translate(content: "let some text data")
        XCTAssertEqual("let some text data translated", translate)
        XCTAssertTrue(transformer.translated)
    }

    
    func testTransformerThrowingCausesError() {
        enum CustomError: Error {
            case generic
        }
        class CustomTransformer: Transformer {
            func transform(formatter: Formatter, options: TransformOptions? = nil) throws {
                throw CustomError.generic
            }
        }
        let transformer = CustomTransformer()
        swiftKotlin = SwiftKotlin(transformers: [transformer])
        let translate = try? swiftKotlin.translate(content: "let some text data")
        XCTAssertNil(translate)
    }

}
