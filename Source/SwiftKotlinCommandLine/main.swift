//
//  main.swift
//  SwiftKotlinCommandLine
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

let swiftKotlin = SwiftKotlin()

let pathViewModel = "/Users/agarcia/Documents/projects/OpenTable-iOS/OpenTableApps/OpenTable-iOS/Modules/Restaurants/List/ViewModel/RestaurantsListViewModel.swift"
let pathService = "/Users/agarcia/Documents/projects/OpenTable-iOS/OpenTableFramework/OpenTableFramework/Services/RestaurantService.swift"

print("\n\n\n\n######### SWIFT CODE#######\n")
let source = try! String(contentsOfFile: pathViewModel)
print(source)

let translation = try! swiftKotlin.translate(content: source)
print("\n\n\n\n######### KOTLIN CODE#######\n")
print(translation)
