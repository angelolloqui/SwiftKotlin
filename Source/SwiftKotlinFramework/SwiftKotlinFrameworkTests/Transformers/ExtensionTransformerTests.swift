//
//  ExtensionTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 04/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class ExtensionTransformerTests: XCTestCase {

    var transformer: ExtensionTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = ExtensionTransformer()
    }
    
    func testExtensionProperties() {
        let swift =
            "extension Double {\n" +
                "\tvar km: Double { return self * 1000.0 }\n" +
                "\tvar m: Double { return self }\n" +
            "}"
        let kotlin =
            "val Double.km: Double { return self * 1000.0 }\n" +
            "val Double.m: Double { return self }\n"
        //Transformation of computed property happening in a different transformer
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testExtensionMethods() {
        let swift =
            "extension Double {\n" +
                "\tfunc toKm() -> Double { return self * 1000.0 }\n" +
                "\tfunc toMeter() -> Double { return self }\n" +
            "}"
        let kotlin =
            "func Double.toKm(): Double { return self * 1000.0 }\n" +
            "func Double.toMeter(): Double { return self }\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    
    func testExtensionStatics() {
        let swift =
            "extension Double {\n" +
                "\tstatic func toKm() -> Double { return self * 1000.0 }\n" +
                "\tstatic var m: Double { return self }\n" +
            "}"
        let kotlin =
            "func Double.Companion.toKm(): Double { return self * 1000.0 }\n" +
            "val Double.Companion.m: Double { return self }\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }


}
