//
//  main.swift
//  SwiftKotlinCommandLine
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

let swiftKotlin = SwiftKotlin()

print("\n\n\n\n######### SWIFT CODE#######\n")
let source = try! String(contentsOfFile: "/Users/agarcia/Documents/projects/OpenTable-iOS/OpenTableFramework/OpenTableFramework/Services/RestaurantService.swift")
print(source)

let translation = try! swiftKotlin.translate(content: source)
print("\n\n\n\n######### KOTLIN CODE#######\n")
print(translation)
