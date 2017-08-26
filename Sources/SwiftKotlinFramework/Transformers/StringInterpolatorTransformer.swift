//
//  StringInterpolatorTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/01/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import Foundation

class StringInterpolatorTransformer: Transformer {
    
    func transform(formatter: Formatter, options: TransformOptions? = nil) throws {
        formatter.forEach(.startOfScope("\"")) { (i, token) in
            if let endOfString = formatter.index(of: .endOfScope("\""), after: i) {
                transformInterpolator(formatter, startIndex: i, endIndex: endOfString)
            }
        }
    }
    
    func transformInterpolator(_ formatter: Formatter, startIndex: Int, endIndex: Int) {
        var index = startIndex + 1
        repeat {
            //Check if token is stringBody ending with "\" and nextToken is scope start "(" and scope ends with ")"
            if let token = formatter.token(at: index),
                token.isStringBody,
                token.string.characters.last == "\\",
                let nextToken = formatter.token(at: index + 1),
                nextToken == .startOfScope("("),
                let endScope = formatter.index(of: .endOfScope(")"), after: index + 1) {
                
                //Replace the last \( by ${ and closing ) by }
                let newStringBody = String(token.string.characters.dropLast())
                formatter.replaceToken(at: index, with: .stringBody(newStringBody))
                formatter.replaceToken(at: index + 1, with: .startOfScope("${"))
                formatter.replaceToken(at: endScope, with: .endOfScope("}"))
                
                index = endScope
            }
            index += 1
        } while index < endIndex
    }
    
}
