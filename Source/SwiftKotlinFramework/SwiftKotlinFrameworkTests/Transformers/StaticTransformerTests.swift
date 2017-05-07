//
//  StaticTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class StaticTransformerTests: XCTestCase {

    var transformer: StaticTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = StaticTransformer()
    }
    
    func testSingleStaticProperty() {
        let swift =
            "class A {\n" +
                "\tpublic static var myBool = true\n" +
            "}"
        let kotlin =
            "class A {\n" +
                "\tcompanion object {\n" +
                    "\t\tpublic var myBool = true\n" +
                "\t}\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    func testMultipleStaticProperties() {
        let swift =
            "class A {\n" +
                "\tstatic private var myBool = true\n" +
                "\tstatic var myNum = 3\n" +
                "\tstatic var myString = \"string\"\n" +
            "}"
        let kotlin =
            "class A {\n" +
                "\tcompanion object {\n" +
                    "\t\tprivate var myBool = true\n" +
                    "\t\tvar myNum = 3\n" +
                    "\t\tvar myString = \"string\"\n" +
                "\t}\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    
    func testSingleStaticMethod() {
        let swift =
            "class A {\n" +
                "\tstatic func method() {}\n" +
            "}"
        let kotlin =
            "class A {\n" +
                "\tcompanion object {\n" +
                    "\t\tfunc method() {}\n" +
                "\t}\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMultipleStaticMethods() {
        let swift =
            "class A {\n" +
                "\tstatic func method() {}\n" +
                "\tstatic func create() -> A? { return nil }\n" +
                "\tstatic func withParams(param: Int) -> A? { return nil }\n" +
            "}"
        let kotlin =
            "class A {\n" +
                "\tcompanion object {\n" +
                    "\t\tfunc method() {}\n" +
                    "\t\tfunc create() -> A? { return nil }\n" +
                    "\t\tfunc withParams(param: Int) -> A? { return nil }\n" +
                "\t}\n" +
        "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMultipleStaticMethodsLinesAndProperties() {
        let swift =
            "class A {\n" +
                "\tvar name = \"string\"\n" +
                "\tstatic var myBool = true\n" +
                "\tstatic func method() {\n" +
                    "\t\tif a {} else {}\n" +
                "\t}\n" +
                "\tfunc test() {}\n" +
            "}"
        let kotlin =
            "class A {\n" +
                "\tvar name = \"string\"\n" +
                "\tcompanion object {\n" +
                    "\t\tvar myBool = true\n" +
                    "\t\tfunc method() {\n" +
                        "\t\t\tif a {} else {}\n" +
                    "\t\t}\n" +
                "\t}\n" +
                "\tfunc test() {}\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testSingleClassFuncMethod() {
        let swift =
            "class A {\n" +
                "\tclass func method() {}\n" +
        "}"
        let kotlin =
            "class A {\n" +
                "\tcompanion object {\n" +
                "\t\tfunc method() {}\n" +
                "\t}\n" +
        "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
}
