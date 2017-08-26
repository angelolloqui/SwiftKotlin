//
//  ConstructorTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Jon Nermut on 1/05/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import Foundation

class ConstructorTransformer: Transformer {
    
    
    func transform(formatter: Formatter, options: TransformOptions? = nil) throws {
        transformInitKeyword(formatter)
    }
    
    func transformInitKeyword(_ formatter: Formatter) {

        formatter.forEach(.keyword("init")) { (i, token) in
            
            // basic keyword replacement
            formatter.replaceToken(at: i, with: .keyword("constructor"))
            
            self.replaceDelegateConstructorCalls(formatter, i: i)
            
            self.removeConvenienceAndRequired(formatter, i: i)
        }
    
    }
    
    func replaceDelegateConstructorCalls(_ formatter: Formatter, i: Int) {
        
        let constructorParamsRange = formatter.nextBracketScope(after: i)
        
        // find the {} scope of the init
        if let bodyScope = formatter.nextBlockScope(after: i) {
            for bodyIndex in bodyScope.lowerBound..<bodyScope.upperBound {
                
                if let token0 = formatter.token(at: bodyIndex),
                    let token1 = formatter.token(at: bodyIndex + 1),
                    let token2 = formatter.token(at: bodyIndex + 2) {
                    
                    if (token0 == .identifier("super") || token0 == .identifier("self"))
                        && token1 == .symbol(".", .infix)
                        && token2 == .identifier("init") {
                                                
                        if let paramRange = formatter.nextBracketScope(after: bodyIndex) {
                            var newTokens: [Token] = [.space(" "), .symbol(":", .infix), .space(" "), token0]
                            for i in paramRange.lowerBound...paramRange.upperBound {
                                var t = formatter.tokens[i]
                                if t == .delimiter(":") {
                                    // replace x: y call syntax with x =y
                                    t = .symbol("=", .infix)
                                    newTokens.append(.space(" "))
                                }

                                newTokens.append(t)
                            }
                            
                            formatter.removeTokens(inRange: bodyIndex...paramRange.upperBound)
                            
                            if let cpr = constructorParamsRange {
                                formatter.insertTokens(newTokens, at: cpr.upperBound + 1)
                            }
                            
                        }
                    }
                }
            }
        }
        
        if let cpr = constructorParamsRange {
            // remove anon params
            for i in cpr.lowerBound..<cpr.upperBound {
                let t = formatter.tokens[i]
                if t == .identifier("_") {
                    formatter.removeToken(at: i)
                    formatter.removeSpacingTokens(at: i)
                }
            }
        }
    }
    
    func removeConvenienceAndRequired(_ formatter: Formatter, i: Int) {
        
        // remove `convenience` and `required` keywords (which are identifiers by the formatter)
        // do this last as we remove tokens before the init()
        
        let startOfLine = formatter.startOfLine(at: i)
        
        for n in (startOfLine..<i).reversed()
        {
            let t =  formatter.token(at: n)
            if t == .identifier("required") || t == .identifier("convenience")
            {
                formatter.removeToken(at: n)
                formatter.removeSpacingTokens(at: n)
            }
        }
    }
    
}
