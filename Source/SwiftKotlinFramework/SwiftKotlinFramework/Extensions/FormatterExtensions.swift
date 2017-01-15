//
//  FormatterExtensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 01/11/16.
//  Extra methods for the SwiftFormat formatter


import Foundation
public struct FormatOptions {}

extension Formatter {
    
    public func removeSpacingTokens(at index: Int) {
        while token(at: index)?.isSpace ?? false {
            removeToken(at: index)
        }
    }

    
    public func removeSpacingOrLinebreakTokens(at index: Int) {
        while token(at: index)?.isSpaceOrLinebreak ?? false {
            removeToken(at: index)
        }
    }

    public func insertTokens(_ tokens: [Token], at index: Int) {
        tokens.reversed().forEach {
            insertToken($0, at: index)
        }
    }
    
    public func insertSpacingTokenIfNone(at index: Int) {
        guard !(token(at: index)?.isSpace ?? false) else { return }
        insertToken(.space(" "), at: index)
    }
    
}
