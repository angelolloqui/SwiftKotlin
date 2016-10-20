//
//  KeywordReplacementTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation


class KeywordResplacementTransformer: Transformer {
    
    func translate(content: String) throws -> String {
        let regex = try! NSRegularExpression(pattern: "\\blet\\b")
        return regex.stringByReplacingMatches(in: content, options: [], range: NSRange(0..<content.characters.count), withTemplate: "val")        
    }
}
