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
        AssertTranslateEquals(translate, kotlin)
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
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testSimpleMethodWithGenerics() {
        let swift =
            "func findRestaurant(restaurantId: Int) -> ServiceTask<Restaurant> {\n" +
            " return NetworkRequestServiceTask<Restaurant>(\n" +
            " networkSession: networkSession,\n" +
            " endpoint: \"restaurants/\")\n" +
            "}"
        
        let kotlin =
            "func findRestaurant(restaurantId: Int) -> ServiceTask<Restaurant> {\n" +
            " return NetworkRequestServiceTask<Restaurant>(\n" +
            " networkSession = networkSession,\n" +
            " endpoint = \"restaurants/\")\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
        
    
    func testMantainsVariableDeclarations() {
        let swift =
            "var a: Int = 4\n" +
            "var b, c, d: Int\n"
        
        let kotlin =
            "var a: Int = 4\n" +
            "var b, c, d: Int\n"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMantainsClassDeclarations() {
        let swift = "class A: B {}"
        let kotlin = "class A: B {}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMantainsStructDeclarations() {        
        let swift = "struct A: B {}"
        let kotlin = "struct A: B {}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    func testMantainsMethodDeclarations() {
        let swift =
            "class A {\n" +
                "\tinit(param1: Int, param2: Int) { }\n" +
                "\tfunc method(param1: Int, param2: Int) { }\n" +
            "}\n"
        let kotlin =
            "class A {\n" +
                "\tinit(param1: Int, param2: Int) { }\n" +
                "\tfunc method(param1: Int, param2: Int) { }\n" +
            "}\n"
        
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMantainsProtocolExtensionDeclarations() {
        let swift =
            "extension Transformer where Self: KeywordResplacementTransformer {}\n" +
            "extension KeywordResplacementTransformer: Transformer {}\n"
        let kotlin =
            "extension Transformer where Self: KeywordResplacementTransformer {}\n" +
            "extension KeywordResplacementTransformer: Transformer {}\n"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }

    
    func testMantainsSwitchCases() {
        let swift =
            "switch nb {\n" +
            "case 0...7, 8, 9: print(data)\n" +
            "default: print(\"default\")\n" +
            "}"
        let kotlin =
            "switch nb {\n" +
            "case 0...7, 8, 9: print(data)\n" +
            "default: print(\"default\")\n" +
            "}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    
    func testMantainsClousureDeclarations() {
        let swift = "service.find(country: \"US\", page: page).onCompletion { (result: RestaurantSearch?) in }"
        let kotlin = "service.find(country = \"US\", page = page).onCompletion { (result: RestaurantSearch?) in }"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    

    
    func testRemovesEmptyMethodNames() {
        let swift = "func greet(_ name: String,_ day: String) -> String {}"
        let kotlin = "func greet(name: String, day: String) -> String {}"
        let translate = try? transformer.translate(content: swift)
        AssertTranslateEquals(translate, kotlin)
    }
    
    

}
