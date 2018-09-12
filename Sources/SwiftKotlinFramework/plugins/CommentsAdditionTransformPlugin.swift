//
//  CommentsAdditionTransformPlugin.swift
//  SwiftKotlinPackageDescription
//
//  Created by Angel Garcia on 22/06/2018.
//

import Foundation
import Transform
import AST
import Source

public class CommentsAdditionTransformPlugin: TokenTransformPlugin {
    public var name: String {
        return "Comments addition"
    }
    
    public var description: String {
        return "Adds parse comments to closest generated element"
    }
    
    public init() {}
    
    func xxx() {
        
    }
/*
    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = tokens
        let sortedComments = topDeclaration.comments.sorted { $0.location.line < $1.location.line }
        var start  = 0
        
        for c in sortedComments {
            var dist = -10000
            var bestTokenIndex = -1
            for (i, t) in newTokens.enumerated() {
                if let tokenRange = t.sourceRange, tokenRange.isValid {
                    if tokenRange.end.line != tokenRange.start.line &&
                    let d = c.location.line - tokenRange.start.line
                    if d <= 0 && d > dist {
                        bestTokenIndex = i + 1
                        dist = d
                    }
                }
            }
            let ct = topDeclaration.newToken(.comment, c.fomattedContent())
            if bestTokenIndex == -1 {
               bestTokenIndex = start
                start += 1
            }
            newTokens.insert(ct, at:bestTokenIndex)
        }
        return newTokens
    }
    */
    
    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = [Token]()
        var sortedComments = topDeclaration.comments.sorted { $0.location.line < $1.location.line }
        
        var position = 0
        while position < tokens.count && !sortedComments.isEmpty {
            let token = tokens[position]
            let comment = sortedComments[0]
            var consumeComment = false
            
            if let tokenRange = token.sourceRange,
                tokenRange.isValid {
//                if token.value == "}" {
//                    print("{")
//                }
                let after = tokenRange.start.isAfter(location: comment.location)
                if after {
                    consumeComment = true
                } else if token.value == "}" && tokenRange.end.isAfter(location: comment.location) && tokenRange.start.isBefore(location: comment.location) {
                    consumeComment = true
                }
            }
            
            if consumeComment, let node = token.node {
                // Consume linbreaks
                if token.kind == .linebreak {
                    newTokens.append(token)
                    position += 1
                }
                // Consume indentations
                while position < tokens.count && tokens[position].kind == .indentation {
                    newTokens.append(tokens[position])
                    position += 1
                }
                newTokens.append(node.newToken(.comment, comment.fomattedContent()))
                sortedComments.removeFirst()
                tokens.lineIndentationToken(at: position).map { newTokens.append($0) }
            } else {
                newTokens.append(token)
                position += 1
            }
        }
        
        newTokens += tokens[position...]
        
        while !sortedComments.isEmpty {
            let comment = sortedComments[0]
            newTokens.append(topDeclaration.newToken(.comment, comment.fomattedContent()))
            sortedComments.removeFirst()
        }
        return newTokens
    }
}

extension Comment {
    func fomattedContent() -> String {
        if content.contains("\n") {
            return "/*\(content)*/\n"
        } else {
            return "//\(content)\n"
        }
    }
}

extension Token {
    var sourceRange: SourceRange? {
        return (origin as? SourceLocatable)?.sourceRange
    }
}

extension SourceRange {
    func contains(location: SourceLocation) -> Bool {
        return start.isBefore(location: location) && end.isAfter(location: location)
    }
}

extension SourceLocation {
    func isBefore(location: SourceLocation) -> Bool {
        guard line != location.line else {
            return column < location.column
        }
        return line < location.line
    }
    
    func isAfter(location: SourceLocation) -> Bool {
        return !isBefore(location: location)
    }
}
