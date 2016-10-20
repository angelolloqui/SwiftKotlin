//
//  SwiftKotlinFrameworkTests.swift
//  SwiftKotlinFrameworkTests
//
//  Created by Angel Garcia on 12/09/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import XCTest
import SourceKittenFramework
@testable import SwiftKotlinFramework

class SwiftKotlinFrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let file = File(path:"/Users/agarcia/Documents/projects/OpenTable-iOS/OpenTableApps/OpenTable-iOS/Modules/Restaurants/Coordinators/RestaurantsCoordinator.swift")
        SwiftKotlin.translate(file)
    }
    
    
}
