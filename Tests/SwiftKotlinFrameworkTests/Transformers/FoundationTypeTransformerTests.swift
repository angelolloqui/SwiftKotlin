//
//  FoundationTypeTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/01/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import XCTest

class FoundationTypeTransformerTests: XCTestCase {

    var transformer: FoundationTypeTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = FoundationTypeTransformer()
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testsAnyBecomesObject() {
        let swift =
            "var anyObject: AnyObject? = nil\n" +
            "var any: Any? = nil\n"
        
        let kotlin =
            "var anyObject: Object? = nil\n" +
            "var any: Object? = nil\n"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    func testsSimpleArrayDeclarationBecomesGenericArray() {
        let swift = "var array: [String]?"
        let kotlin = "var array: Array<String>?"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testsGenericArrayDeclarationBecomesGenericArray() {
        let swift = "var array: Promise<[String]>?"
        let kotlin = "var array: Promise<Array<String>>?"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testsNestedGenericArraysDeclarationBecomesNestedGenericArrays() {
        let swift = "var array: [Promise<[String]>]"
        let kotlin = "var array: Array<Promise<Array<String>>>"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    func testsArrayValueDeclarationIsChanged() {
        let swift = "var array = [\"1\", \"2\"]"
        let kotlin = "var array = arrayOf(\"1\", \"2\")"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testsSimpleDictDeclarationBecomesGenericMap() {
        let swift = "var map: [Int: String]?"
        let kotlin = "var map: Map<Int, String>?"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testsGenericDictDeclarationBecomesGenericMap() {
        let swift = "var map: Promise<[Int: String]>?"
        let kotlin = "var map: Promise<Map<Int, String>>?"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testsNestedGenericDictDeclarationBecomesNestedGenericMaps() {
        let swift = "var map: [Int: Promise<[String: String]>]"
        let kotlin = "var map: Map<Int, Promise<Map<String, String>>>"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testsMapValueDeclarationIsChanged() {
        let swift = "var map = [1: \"a\", 2: \"b\"]"
        let kotlin = "var map = mapOf(1 to \"a\", 2 to \"b\")"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }


}
