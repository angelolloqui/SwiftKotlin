//
//  NameParametersTransformerTests.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest

class NameParametersTransformerTests: XCTestCase {
    var transformer: NameParametersTransformer!
    
    override func setUp() {
        super.setUp()
        transformer = NameParametersTransformer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testMethodParameters() {
        let swift = "restaurantService.findRestaurant(restaurantId: restaurant.id, param: param)"
        let kotlin = "restaurantService.findRestaurant(restaurantId = restaurant.id, param = param)"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }

    
    func testInitParameters() {
        let swift =
            "NetworkRequestServiceTask(\n" +
            "networkSession: networkSession,\n" +
            "endpoint: \"restaurants\")"
        
        let kotlin =
            "NetworkRequestServiceTask(\n" +
            "networkSession = networkSession,\n" +
            "endpoint = \"restaurants\")"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    
    
    func testMantainsDeclarations() {
        let swift =
            "var a: Int = 4\n" +
            "class A: B { \n" +
                "init(param: Int) { }\n" +
                "func method(param: Int) { }\n" +
            "}"
        let kotlin =
            "var a: Int = 4\n" +
            "class A: B { \n" +
                "init(param: Int) { }\n" +
                "func method(param: Int) { }\n" +
            "}"
        
        let translate = try? transformer.translate(content: swift)
        XCTAssertEqual(translate, kotlin)
    }
    
    
    


}
