//
//  ConditionalCompilationTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Jon Nermut on 14/05/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import Foundation
import JavaScriptCore

/* 
 Swift 3.1 conditional compilation grammar from
 https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/zzSummaryOfTheGrammar.html
 
 GRAMMAR OF A CONDITIONAL COMPILATION BLOCK
 
 conditional-compilation-block → if-directive-clause ­elseif-directive-clauses­ opt ­else-directive-clause­ opt ­endif-directive­
 if-directive-clause → if-directive­ compilation-condition ­statements­ opt ­
 elseif-directive-clauses → elseif-directive-clause­ elseif-directive-clauses­ opt ­
 elseif-directive-clause → elseif-directive­ compilation-condition ­statements­ opt ­
 else-directive-clause → else-directive­ statements­ opt ­
 if-directive → #if­
 elseif-directive → #elseif­
 else-directive → #else­
 endif-directive → #endif­
 
 compilation-condition → platform-condition­
 compilation-condition → identifier­
 compilation-condition → boolean-literal­
 compilation-condition → (­compilation-condition­)­
 compilation-condition → !­compilation-condition­
 compilation-condition → compilation-condition­&&­compilation-condition­
 compilation-condition → compilation-condition­||­compilation-condition­
 
 platform-condition → os­(­operating-system­)­
 platform-condition → arch­(­architecture­)­
 platform-condition → swift­(­>=­swift-version­)­
 operating-system → macOS­  iOS­  watchOS­  tvOS­
 architecture → i386­  x86_64­  arm­  arm64­
 swift-version → decimal-digits­swift-version-continuation­ opt ­
 swift-version-continuation → .­decimal-digits­swift-version-continuation­ opt 
 
 */



/// Executes #if / #else / #endif conditional compilation by evaulating conditions and removing blocks
class ConditionalCompilationTransformer: Transformer {

    
    static var jsContext: JSContext = {
        let context = JSContext()
        let _ = context?.evaluateScript("function os() { return false }\n" +
                                        "function arch() { return false }\n")
        return context!;
    }()

    
    func transform(formatter: Formatter, options: TransformOptions? = nil) throws {
        formatter.print()
        
        let start = Token.startOfScope("#if")
        let end = Token.endOfScope("#endif")
        
        // find all #if blocks
        formatter.forEach(start) {
            (i, token) in
            
            // find the entire construct
            guard let fullScope = formatter.nextScope(after: i-1, start: .startOfScope("#if"), end: .endOfScope("#endif")) else { return }
            
            // we run a little state machine to evaluate the entire block, while not messing with nested #if/#else
            var buffer = Array<Token>()
            var appending = false
            var scope = 0
            var tokenIndex = i-1
            repeat {
                tokenIndex += 1
                guard let token = formatter.token(at: tokenIndex) else { break }
                
                if token == end {
                    scope -= 1
                }
                else if token == start {
                    scope += 1
                    
                    if scope == 1
                    {
                        // evaluate the condition
                        let expr = evaluateCondition(formatter: formatter, index: tokenIndex)
                        appending = expr // if it evaluated true, we are now appending
                        // skip to EOL
                        tokenIndex = formatter.endOfLine(after: tokenIndex)
                    }
                }
                else if scope == 1 && token == .keyword("#elseif")
                {
                    
                }
                else if scope == 1 && token == .keyword("#else")
                {
                    
                }
                else
                {
                    if appending
                    {
                        buffer.append(token)
                    }
                }
                
            } while  scope > 0
            
            // replace the whole block with the buffer
            formatter.replaceTokens(inRange: i...tokenIndex, with: buffer)
        }
    }
    
    func evaluateCondition(formatter: Formatter, index: Int) -> Bool
    {
        let endOfLine = formatter.endOfLine(after: index)
        
        let expression = formatter.toString(index+1..<endOfLine)
        
        let jsc = ConditionalCompilationTransformer.jsContext
        
        let script = "!!(\(expression))" // the !! is a simple coerce to boolean in JS
        guard let jsv = jsc.evaluateScript(script) else { return false }
        
        let ret = jsv.isBoolean && jsv.toBool()
        
        print("Evaluated expression: \(expression) as \(ret)")
        
        return ret
    }
}
