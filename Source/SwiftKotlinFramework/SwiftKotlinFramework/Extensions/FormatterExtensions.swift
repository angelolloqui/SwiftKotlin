//
//  FormatterExtensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 01/11/16.
//  Extra methods for the SwiftFormat formatter


import Foundation
struct FormatOptions {}

extension Formatter {
    
    public func removeSpacingTokensAtIndex(_ index: Int) {
        while tokenAtIndex(index)?.isWhitespace ?? false {
            removeTokenAtIndex(index)
        }
    }
    
    public func insertTokens(_ tokens: [Token], atIndex index: Int) {
        tokens.reversed().forEach {
            insertToken($0, atIndex: index)
        }
    }
    
}
