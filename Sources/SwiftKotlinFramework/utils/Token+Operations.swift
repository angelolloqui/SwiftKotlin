//
//  Token+Operations.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 03/09/2017.
//

import Transform

extension Collection where Iterator.Element == [Token] {
    public func joined(tokens: [Token]) -> [Token] {
        return Array(self.filter { !$0.isEmpty }.flatMap { $0 + tokens }.dropLast(tokens.count))
    }

    public func joined() -> [Token] {
        return self.flatMap { $0 }
    }
}

extension Array where Iterator.Element == Token {
    func replacing(_ condition: (Token) -> Bool, with tokens: [Token], amount: Int = Int.max) -> [Token] {
        var count = 0
        var newTokens = [Token]()
        for token in self {
            if count < amount && condition(token) {
                newTokens.append(contentsOf: tokens)
                count+=1
            } else {
                newTokens.append(token)
            }
        }
        return newTokens
    }

    func removingTrailingSpaces() -> [Token] {
        var lastToken: Token?
        var newTokens = [Token]()
        for token in self {
            if token.kind == .linebreak && lastToken?.kind == .space {
                lastToken = nil
            }
            if lastToken != nil {
                newTokens.append(lastToken!)
            }
            lastToken = token
        }
        if lastToken != nil {
            newTokens.append(lastToken!)
        }
        return newTokens
    }

    func lineIndentationToken(at index: Int) -> Token? {
        guard let firstIndentation = indexOf(kind: .indentation, before: index) else { return nil }

        if let firstLineBreak = indexOf(kind: .linebreak, before: index), firstIndentation < firstLineBreak {
            return nil
        }

        return self[firstIndentation]
    }

    func indexOf(kind: Token.Kind, before: Int) -> Int? {
        var index = before
        while index >= 0 {
            if self[index].kind == kind {
                return index
            }
            index -= 1
        }
        return nil
    }


    func indexOf(kind: Token.Kind, after: Int) -> Int? {
        var index = after
        while index >= 0 {
            if self[index].kind == kind {
                return index
            }
            index += 1
        }
        return nil
    }
}

