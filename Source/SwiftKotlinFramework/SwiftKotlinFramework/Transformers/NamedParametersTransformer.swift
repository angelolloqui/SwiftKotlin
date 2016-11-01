//
//  NamedParametersTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class NameParametersTransformer: Transformer {
    
    func translate(content: String) throws -> String {
        return try replaceFirstNamedParameter(content: content)
    }
    
    
    func replaceFirstNamedParameter(content: String) throws -> String {
       
        let callExpressions = try findMethodCallExpressions(content: content)
        
//        return words.reduce(content) { (translate, word) -> String in
//            let replacement = word.replacingOccurrences(of: ":", with: " = ")
//            return translate.replacingOccurrences(of: word, with: replacement)
//        }
        
        return content
    }
    
    func findMethodCallExpressions(content: String) throws -> [Int] {
        //\.(\w+)\( finds any expresion with format ".method("
        let regex1 = try NSRegularExpression(pattern: "\\.(\\w+)\\(")
        let locations1 = regex1.matches(in: content, options: [], range: NSRange(0..<content.characters.count)).map { $0.range.location + 1 }
        
        //(\w+)?\s+(\w+)\( finds any expresion with format "word word(" and captures the 2 words to analyze.
        let regex2 = try NSRegularExpression(pattern: "(\\w+)?\\s+(\\w+)\\(")
        let locations2 = regex2.matches(in: content, options: [], range: NSRange(0..<content.characters.count)).flatMap { match -> Int? in
            return nil
        }
        
        return locations1 + locations2
    }
}
