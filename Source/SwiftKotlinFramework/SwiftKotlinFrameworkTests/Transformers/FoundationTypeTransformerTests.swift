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


}
