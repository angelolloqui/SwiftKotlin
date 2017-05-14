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
    
    override func setUp() {
        super.setUp()
        transformer = ConditionalCompilationTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConditionalIf() {
        let swift =
            "#if SOMETHING\n" +
            "print(\"hello\")\n" +
            "#endif\n"
        
        let kotlin = "\n" 
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testConditionalIfElse() {
        let swift =
            "#if SOMETHING\n" +
            "print(\"hello 1\")\n" +
            "#elseif SSOMETHINGELSE\n" +
            "print(\"hello 2\")\n" +
            "#else\n" +
            "print(\"hello 3\")\n" +
            "#endif\n"
        
        let kotlin = "print(\"hello 3\")\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
}
