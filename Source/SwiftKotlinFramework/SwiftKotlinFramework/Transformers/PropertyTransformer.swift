//
//  PropertyTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 03/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class PropertyTransformer: Transformer {
    
    func transform(formatter: Formatter) throws {
        transformComputedProperties(formatter)
    }
    
    func transformComputedProperties(_ formatter: Formatter) {
        let computedProperties = findComputedPropertyBodyIndexes(formatter)
        
        computedProperties.forEach { index in
            //Remove }
            guard let bodyEndIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0.string == "}" }) else { return }
            formatter.removeTokenAtIndex(bodyEndIndex)
            formatter.removeSpacingTokensAtIndex(bodyEndIndex - 1)
            
            //Remove "return"
            if let returnIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0.string == "return" }) {
                formatter.removeTokenAtIndex(returnIndex)
                formatter.removeSpacingTokensAtIndex(returnIndex)
            }
            
            //Replace "{" by "get() ="
            formatter.replaceTokenAtIndex(index, with: Token(.symbol, "="))
            formatter.insertToken(Token(.whitespace, " "), atIndex: index)
            formatter.insertToken(Token(.endOfScope, ")"), atIndex: index)
            formatter.insertToken(Token(.startOfScope, "("), atIndex: index)
            formatter.insertToken(Token(.identifier, "get"), atIndex: index)
            //Add extra space if none
            if formatter.tokenAtIndex(index - 1)?.type != .whitespace {
                formatter.insertToken(Token(.whitespace, " "), atIndex: index)
            }
            
            //Replace var by val
            if let varIndex = formatter.indexOfPreviousToken(fromIndex: index, matching: { $0.string == "var" }) {
                formatter.replaceTokenAtIndex(varIndex, with: Token(.identifier, "val"))
            }
        }
    }
    
    
    func findComputedPropertyBodyIndexes(_ formatter: Formatter) -> [Int] {
        //Find properties with the type: "var <name>:<type> {"
        
        var indexes = [Int]()
        formatter.forEachToken("var", ofType: .identifier) { (i, token) in
            var index = i + 1
            
            //Consume spaces
            while formatter.tokenAtIndex(index)?.isWhitespaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Consume name
            index += 1
            
            //Consume possible spaces
            while formatter.tokenAtIndex(index)?.isWhitespaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a : and consume
            guard formatter.tokenAtIndex(index)?.string == ":" else { return }
            index += 1
            
            //Consume possible spaces
            while formatter.tokenAtIndex(index)?.isWhitespaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Now consume identifiers, maps and generics
            while   let token = formatter.tokenAtIndex(index),
                    token.type == .identifier || token.string == "<" || token.string == ">" || token.string == "[" || token.string == "]" || token.string == "?" || token.string == "." {
                index += 1
            }
            
            //Consume possible spaces
            while formatter.tokenAtIndex(index)?.isWhitespaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a { and add to list
            guard formatter.tokenAtIndex(index)?.string == "{" else { return }
            indexes.append(index)
        }
        return indexes
    }
}
