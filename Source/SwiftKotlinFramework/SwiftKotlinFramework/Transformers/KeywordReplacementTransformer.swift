//
//  KeywordReplacementTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation


class KeywordResplacementTransformer: Transformer {
    let replacementMap = [
        "\\bprotocol\\b": "interface",
        "\\blet\\b": "val",
        "\\bfunc\\b": "fun",
        "\\bself\\b": "this",
        "\\$0\\b": "it",        
    ]
    
    func translate(content: String) throws -> String {
        return try replacementMap.reduce(content) { (translate, replace) throws -> String in
            let regex = try NSRegularExpression(pattern: replace.key)
            return regex.stringByReplacingMatches(in: translate, options: [], range: NSRange(0..<translate.characters.count), withTemplate: replace.value)
        }
    }
}
