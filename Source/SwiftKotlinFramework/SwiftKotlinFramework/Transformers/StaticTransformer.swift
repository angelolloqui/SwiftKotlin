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
        
        formatter.forEach(.keyword("static")) {  (i, token) in
            guard let lineBreakIndex = formatter.index(of: .linebreak, before: i) else { return }
            let startIndex = lineBreakIndex + 1
            if firstStaticIndex == nil {
                firstStaticIndex = startIndex
            }
            if indentation == nil {
                indentation = formatter.indentTokenForLineAtIndex(startIndex)
            }
            
            //Remove static keyword
            formatter.removeToken(at: i)
            formatter.removeSpacingTokensAtIndex(i)
            
            //Check if it is a func or a var/let and get the scope end index for it
            var scopeEndIndex: Int? = nil
            var index = startIndex
            repeat {
                index += 1
                guard let token = formatter.token(at: index) else { return }
                if token == .keyword("var") || token == .keyword("let") {
                    scopeEndIndex = indexOfEndScopeForProperty(formatter, at: index)
                }
                else if token == .keyword("func") {
                    scopeEndIndex = indexOfEndScopeForFunction(formatter, at: index)
                }
            } while scopeEndIndex == nil
            
            //Extract the whole declaration
            staticDeclarations.append(Array(formatter.tokens[startIndex...scopeEndIndex!]))
            formatter.removeTokens(inRange: Range(uncheckedBounds: (startIndex, scopeEndIndex! + 1)))
        }
        
        //Add companion and insert all declarations
        if let firstStaticIndex = firstStaticIndex {
            
            var tokens: [Token] = [
                indentation ?? .space("\t"),
                .keyword("companion"),
                .space(" "),
                .keyword("object"),
                .space(" "),
                .startOfScope("{"),
                .linebreak("\n"),
            ]
            
            //Insert declarations
            staticDeclarations.forEach {
                tokens.append(contentsOf: addExtraIndentToDeclarations($0))
            }
            tokens.append(contentsOf: [
                indentation ?? .space("\t"),
                .endOfScope("}"),
                .linebreak("\n"),
            ])
            formatter.insertTokens(tokens, at: firstStaticIndex)
        }
    }
    
    func indexOfEndScopeForProperty(_ formatter: Formatter, at: Int) -> Int? {
        return formatter.indexOfNextToken(fromIndex: atIndex, matching: { $0.isLinebreak })
    }    
    
    func indexOfEndScopeForFunction(_ formatter: Formatter, at: Int) -> Int? {
        guard let bodyStartIndex = formatter.indexOfNextToken(fromIndex: atIndex + 1, matching: { $0 == .startOfScope("{") }) else { return nil }
        guard let bodyEndIndex = formatter.indexOfNextToken(fromIndex: bodyStartIndex, matching: { $0 == .endOfScope("}") }) else { return nil }
        return bodyEndIndex + 1
    }
    
    func addExtraIndentToDeclarations(_ tokens:[Token]) -> [Token] {
        var newLine = true
        var newTokens: [Token] = []
        tokens.forEach {
            if newLine && !$0.isLinebreak {
                newTokens.append(.space("\t"))
            }
            newTokens.append($0)
            newLine = $0.isLinebreak
        }
        return newTokens
    }
}
