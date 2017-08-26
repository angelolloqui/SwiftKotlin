//
//  StructTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class StructTransformerTests: XCTestCase {
    var transformer: StructTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = StructTransformer()
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testsStructBecomesDataClass() {
        let swift =
            "struct A {\n" +
                "\tvar myBool = true\n" +
            "}"
        let kotlin =
            "data class A {\n" +
                "\tvar myBool = true\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }


}
