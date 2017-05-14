//
//  File.swift
//  SwiftKotlinFramework
//
//  Created by Jon Nermut on 14/05/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import Foundation
import XCTest

class ConditionalCompilationTransformerTests: XCTestCase {
    var transformer: ConditionalCompilationTransformer!
    
    
    let ifElseTest =
        "#if SOMETHING1\n" +
        "print(\"hello 1\")\n" +
        "#elseif SOMETHING2\n" +
        "print(\"hello 2\")\n" +
        "#else\n" +
        "print(\"hello 0\")\n" +
        "#endif\n"
    
    override func setUp() {
        super.setUp()
        transformer = ConditionalCompilationTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConditionalIf() {
        
        var options = TransformOptions()
        
        let swift =
            "#if SOMETHING\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        
        let kotlin1 = ""
        let translate1 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate1, kotlin1)
        
        // now define the condition
        options.defines.append("SOMETHING")
        
        // now it should all compile
        let kotlin2 = "print(\"hello\")\n"
        let translate2 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate2, kotlin2)
    }
    
    func testConditionalIfElse0() {
        let options = TransformOptions()
        let swift = ifElseTest
        
        let kotlin = "print(\"hello 0\")\n" // with nothing defined
        let translate = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testConditionalIfElse1() {
        var options = TransformOptions()
        let swift = ifElseTest
        options.defines.append("SOMETHING1")
        let kotlin = "print(\"hello 1\")\n" // with SOMETHING1 defined
        let translate = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testConditionalIfElse2() {
        var options = TransformOptions()
        let swift = ifElseTest
        options.defines.append("SOMETHING2")
        let kotlin = "print(\"hello 2\")\n" // with SOMETHING2 defined
        let translate = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testConditionalOs1() {
        
        let options = TransformOptions()
        let swift =
            "#if os(iOS)\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        
        let kotlin1 = ""
        let translate1 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate1, kotlin1)
        
    }
    
    func testConditionalOs2() {
        
        let options = TransformOptions()
        let swift =
            "#if os(iOS) || os(macOS)\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        
        let kotlin1 = ""
        let translate1 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate1, kotlin1)
        
    }
    
    func testConditionalOs3() {
        
        var options = TransformOptions()
        let swift =
            "#if os(iOS) || SOMETHING\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        options.defines.append("SOMETHING")
        let kotlin1 = "print(\"hello\")\n"
        let translate1 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate1, kotlin1)
        
    }
    
    func testConditionalIfWithOr() {
        
        var options = TransformOptions()
        
        let swift =
            "#if SOMETHING || SOMETHING2\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        
        let kotlin1 = ""
        let translate1 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate1, kotlin1)
        
        // now define the condition
        options.defines.append("SOMETHING")
        
        // now it should all compile
        let kotlin2 = "print(\"hello\")\n"
        let translate2 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate2, kotlin2)
    }
    
    func testConditionalIfWithAnd() {
        
        var options = TransformOptions()
        
        let swift =
            "#if SOMETHING && SOMETHING2\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        
        let kotlin1 = ""
        let translate1 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate1, kotlin1)
        
        // now define the condition
        options.defines.append("SOMETHING2")
        
        // still nothing
        let kotlin2 = ""
        let translate2 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate2, kotlin2)
        
        options.defines = ["SOMETHING", "SOMETHING2"];
        
        let kotlin3 = "print(\"hello\")\n"
        let translate3 = try? transformer.translate(content: swift, options: options)
        AssertTranslateEquals(translate3, kotlin3)
    }
}
