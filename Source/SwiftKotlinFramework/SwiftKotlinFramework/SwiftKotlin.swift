//
//  SwiftKotlin.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/09/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

protocol Transformer {
    func translate(content: String) throws -> String
}

class SwiftKotlin: Transformer {
    let transformers = [KeywordResplacementTransformer()]
        
    func translate(content: String) throws -> String {
        //Transform each element
        return try transformers.reduce(content) { (translated, transformer) throws -> String in
            return try transformer.translate(content: translated)
        }
    }
}
