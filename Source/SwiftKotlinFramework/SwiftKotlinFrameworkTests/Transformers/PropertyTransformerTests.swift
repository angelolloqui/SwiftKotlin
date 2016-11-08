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
        XCTFail()
    }
    
    func testPrivateSetterModifierProperty() {
        XCTFail()
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
        XCTFail()
    }
}
