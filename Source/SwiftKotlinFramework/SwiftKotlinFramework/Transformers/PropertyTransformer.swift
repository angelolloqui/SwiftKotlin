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
        var previousIndex = 0
        while let index = findFirstPropertyBodyIndex(formatter, fromIndex: previousIndex) {
            //Find a get or set keyword
            let getIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0 == .identifier("get")})
            let setIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0 == .identifier("set")})
            
            //Convert the getter if a getter is defined or there is no setter
            if getIndex != nil || setIndex == nil {
                transformaGetterProperty(formatter, index: getIndex ?? index)
            }
            
            //Replace var by val if no setter
            if  setIndex == nil,
                let varIndex = formatter.indexOfPreviousToken(fromIndex: index, matching: { $0.string == "var" }) {
                formatter.replaceTokenAtIndex(varIndex, with: .keyword("val"))
            }
            
            //If there is a "get" or "set" then remove the {} from the property
            if  getIndex != nil || setIndex != nil,
                let closeIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0 == .endOfScope("}") }) {
                formatter.removeTokenAtIndex(closeIndex)
                formatter.removeTokenAtIndex(index)
            }
            
            previousIndex = index
        }
    }
    
    func transformaGetterProperty(_ formatter: Formatter, index: Int) {
        //Add "get() " before the "{"
        formatter.insertToken(.whitespace(" "), atIndex: index)
        formatter.insertToken(.endOfScope(")"), atIndex: index)
        formatter.insertToken(.startOfScope("("), atIndex: index)
        formatter.insertToken(.keyword("get"), atIndex: index)
        
        //Add extra space if none
        if !(formatter.tokenAtIndex(index - 1)?.isWhitespace ?? false) {
            formatter.insertToken(.whitespace(" "), atIndex: index)
        }
    }
    
    func findFirstPropertyBodyIndex(_ formatter: Formatter, fromIndex: Int) -> Int? {
        //Find properties with the type: "var <name>:<type> {"
        for i in fromIndex..<formatter.tokens.count {
            guard formatter.tokenAtIndex(i) == .keyword("var") else { continue }
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
            guard formatter.tokenAtIndex(index)?.string == ":" else { continue }
            index += 1
            
            //Consume possible spaces
            while formatter.tokenAtIndex(index)?.isWhitespaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Now consume identifiers, maps, optionals, unwrapping and generics
            while   let token = formatter.tokenAtIndex(index),
                    token.isIdentifier || token.string == "<" || token.string == ">" || token.string == "[" || token.string == "]" || token.string == "?" || token.string == "!" || token.string == "." {
                index += 1
            }
            
            //Consume possible spaces
            while formatter.tokenAtIndex(index)?.isWhitespaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a { and add to list
            guard formatter.tokenAtIndex(index)?.string == "{" else { continue }
            return index
        }
        return nil
    }
}
