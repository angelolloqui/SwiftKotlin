//
//  PropertyTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class PropertyTransformerTests: XCTestCase {
    var transformer: PropertyTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = PropertyTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSingleGetterProperty() {
        let swift = "var stateObservable: Observable<RestaurantsListState> { return state.asObservable() }"
        let kotlin = "val stateObservable: Observable<RestaurantsListState> get() { return state.asObservable() }"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testMultipleGetterProperties() {
        let swift =
            "var stateObservable: Observable<RestaurantsListState> { return state.asObservable() }\n" +
            "var loadingObservable: Observable<Bool> { return loadingSubject.asObservable() }"
        let kotlin =
            "val stateObservable: Observable<RestaurantsListState> get() { return state.asObservable() }\n" +
            "val loadingObservable: Observable<Bool> get() { return loadingSubject.asObservable() }"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    func testExplicitGetterProperty() {
        let swift =
            "var stateObservable: Observable<RestaurantsListState> {\n" +
                "\tget {\n" +
                    "\t\treturn state.asObservable()\n" +
                "\t}\n" +
            "}"
        let kotlin =
            "val stateObservable: Observable<RestaurantsListState> \n" +
                "\tget() {\n" +
                    "\t\treturn state.asObservable()\n" +
                "\t}\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testSetterPropertyWithName() {
        let swift =
            "var center: Point {\n" +
                "\tset(newValue){\n" +
                    "\t\torigin.x = newValue.x - 100\n" +
                "\t}\n" +
            "}"
        let kotlin =
            "var center: Point \n" +
                "\tset(newValue){\n" +
                    "\t\torigin.x = newValue.x - 100\n" +
                "\t}\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testSetterPropertyWithNoName() {
        let swift =
            "var center: Point {\n" +
                "\tset {\n" +
                    "\t\torigin.x = newValue.x - 100\n" +
                "\t}\n" +
            "}"
        let kotlin =
            "var center: Point \n" +
                "\tset(newValue) {\n" +
                    "\t\torigin.x = newValue.x - 100\n" +
                "\t}\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testGetterAndSetterProperty() {
        let swift =
            "var center: Point {\n" +
                "\tget {\n" +
                    "\t\treturn Point(x: centerX, y: centerY)\n" +
                "\t}\n" +
                "\tset {\n" +
                    "\t\torigin.x = newValue.x - 100\n" +
                "\t}\n" +
            "}"
        let kotlin =
            "var center: Point \n" +
                "\tget() {\n" +
                    "\t\treturn Point(x: centerX, y: centerY)\n" +
                "\t}\n" +
                "\tset(newValue) {\n" +
                    "\t\torigin.x = newValue.x - 100\n" +
                "\t}\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testPrivateSetterModifierProperty() {
        let swift = "\tprivate(set) var numberOfEdits = 0\n"
        let kotlin = "\tvar numberOfEdits = 0\n\t\tprivate set\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testDidSetProperty() {
        XCTFail()
    }
    
    func testWillSetProperty() {
        XCTFail()
    }
    
    func testLazyStoredProperty() {
        XCTFail()
    }
    
    func testLateInitProperty() {
        let swift = "var subject: TestSubject!"
        let kotlin = "lateinit var subject: TestSubject"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testProtocolProperties() {
        let swift = "protocol Hello {\n" +
                        "var foo: String { get }\n" +
                        "var bar: String { get set }\n" +
                        "}"

        let kotlin = "protocol Hello {\n" + // protocol to interface is done by teh KeywordTransformer
            "val foo: String  \n" +
            "var bar: String  \n" +
        "}"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
}
