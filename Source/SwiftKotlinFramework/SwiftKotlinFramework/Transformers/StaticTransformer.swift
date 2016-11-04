//
//  StaticTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 04/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class StaticTransformer: Transformer {
    
    func transform(formatter: Formatter) throws {
        
        //Extract all static declarations
        var firstStaticIndex: Int?
        var indentation: Token?
        var staticDeclarations = [[Token]]()
        formatter.forEachToken(.keyword("static")) {  (i, token) in
            guard let lineBreakIndex = formatter.indexOfPreviousToken(fromIndex: i, matching: { $0.isLinebreak }) else { return }
            let startIndex = lineBreakIndex + 1
            if firstStaticIndex == nil {
                firstStaticIndex = startIndex
            }
            if indentation == nil {
                indentation = formatter.indentTokenForLineAtIndex(startIndex)
            }
            
            //Remove static keyword
            formatter.removeTokenAtIndex(i)
            formatter.removeSpacingTokensAtIndex(i)
            
            //Check if it is a func or a var/let and get the scope end index for it
            var scopeEndIndex: Int? = nil
            var index = startIndex
            repeat {
                index += 1
                guard let token = formatter.tokenAtIndex(index) else { return }
                if token == .keyword("var") || token == .keyword("let") {
                    scopeEndIndex = indexOfEndScopeForProperty(formatter, atIndex: index)
                }
                else if token == .keyword("func") {
                    scopeEndIndex = indexOfEndScopeForFunction(formatter, atIndex: index)
                }
            } while scopeEndIndex == nil
            
            //Extract the whole declaration
            staticDeclarations.append(Array(formatter.tokens[startIndex...scopeEndIndex!]))
            formatter.removeTokensInRange(Range(uncheckedBounds: (startIndex, scopeEndIndex! + 1)))
        }
        
        //Add companion and insert all declarations
        if let firstStaticIndex = firstStaticIndex {
            
            var tokens: [Token] = [
                indentation ?? .whitespace("\t"),
                .keyword("companion"),
                .whitespace(" "),
                .keyword("object"),
                .whitespace(" "),
                .startOfScope("{"),
                .linebreak("\n"),
            ]
            
            //Insert declarations
            staticDeclarations.forEach {
                tokens.append(.whitespace("\t"))
                tokens.append(contentsOf: $0)
            }
            tokens.append(contentsOf: [
                indentation ?? .whitespace("\t"),
                .endOfScope("}"),
                .linebreak("\n"),
            ])
            formatter.insertTokens(tokens, atIndex: firstStaticIndex)
        }
    }
    
    func indexOfEndScopeForProperty(_ formatter: Formatter, atIndex: Int) -> Int? {
        return formatter.indexOfNextToken(fromIndex: atIndex, matching: { $0.isLinebreak })
    }
    
    
    func indexOfEndScopeForFunction(_ formatter: Formatter, atIndex: Int) -> Int? {
        return nil
    }
}
