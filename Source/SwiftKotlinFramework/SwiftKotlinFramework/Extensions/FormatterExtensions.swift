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

        
    /// Finds the next matched pair of { } after the given index. Indices are inclusive.
    public func nextBlockScope(after index: Int) -> ClosedRange<Int>?
    {
        return nextScope(after: index, start: .startOfScope("{"), end: .endOfScope("}"))
    }
    
    /// Finds the next matched pair of ( ) after the given index. Indices are inclusive.
    public func nextBracketScope(after index: Int) -> ClosedRange<Int>?
    {
        return nextScope(after: index, start: .startOfScope("("), end: .endOfScope(")"))
    }
    
    /// Finds the next matched pair of { } after the given index. Indices are inclusive.
    public func nextScope(after index: Int, start: Token, end: Token) -> ClosedRange<Int>?
    {
        
        guard let bodyStartIndex = self.index(of: start, after: index) else { return nil }
        
        var scopeCount = 1
        var tokenIndex = bodyStartIndex
        repeat {
            tokenIndex += 1
            guard let token = self.token(at: tokenIndex) else { return nil }
            
            if token == end {
                scopeCount -= 1
            }
            else if token == start {
                scopeCount += 1
            }
        } while  scopeCount > 0
        
        return ClosedRange<Int>(uncheckedBounds: (bodyStartIndex, tokenIndex))
    }
    
    
}
