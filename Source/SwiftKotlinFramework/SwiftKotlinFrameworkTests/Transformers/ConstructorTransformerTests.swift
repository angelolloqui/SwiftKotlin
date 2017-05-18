//
//  ConstructorTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class ConstructorTransformerTests: XCTestCase {
    var transformer: ConstructorTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = ConstructorTransformer()
    }
    
    func testMostBasicConstructor() {
        let swift = "init() {}"
        let kotlin = "constructor() {}"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testConstructorWithAnonParam() {
        let swift = "init(_ foo: bar) {}"
        let kotlin = "constructor(foo: bar) {}"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testConvenienceAndRequired() {
        let swift = "public convenience init() {}\n" +
                    "required public init() {}\n" +
                    "required convenience init() {}"
        let kotlin = "public constructor() {}\n" +
                    "public constructor() {}\n" +
                    "constructor() {}"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testSuperInit() {
        let swift = "init() { super.init() }\n" +
                    "init() { super.init(foo) }\n" +
                    "init() { super.init(foo: bar) }"
        let kotlin = "constructor() : super() {  }\n" +
                    "constructor() : super(foo) {  }\n" +  // param transformation should be done be FunctionParameterTransformer
                    "constructor() : super(foo= bar) {  }"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    func testSelfInit() {
        let swift = "init() { self.init() }\n" +
                    "init() { self.init(foo) }\n" +
                    "init() { self.init(foo: bar) }"
        let kotlin = "constructor() : this() {  }\n" +
                    "constructor() : this(foo) {  }\n" +  // param transformation should be done be FunctionParameterTransformer
                    "constructor() : this(foo= bar) {  }"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
}
