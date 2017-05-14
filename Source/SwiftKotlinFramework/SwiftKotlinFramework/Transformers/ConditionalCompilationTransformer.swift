//
//  ConditionalCompilationTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Jon Nermut on 14/05/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import Foundation

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

    
    func transform(formatter: Formatter) throws {
       formatter.print()
    }
}
