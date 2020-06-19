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
    
    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = [Token]()
        var sortedComments = topDeclaration.comments.sorted { $0.location.line < $1.location.line }

        var position = 0
        while position < tokens.count && (!sortedComments.isEmpty || tokens[position].kind == .linebreak) {
            let token = tokens[position]
            let comment = sortedComments.first
            var consumeComment = false
            
            if let comment = comment, let tokenRange = token.sourceRange,
                tokenRange.isValid {
                
                if tokenRange.start.isAfter(location: comment.location) {
                    consumeComment = true
                }
            }
            
            if consumeComment, let comment = comment, let node = token.node {
                // Consume indentations
                while position < tokens.count && tokens[position].kind == .indentation {
                    newTokens.append(tokens[position])
                    position += 1
                }                
                newTokens.append(node.newToken(.comment, comment.fomattedContent()))
                sortedComments.removeFirst()
                tokens.lineIndentationToken(at: position).map { newTokens.append($0) }
            } else {
                if token.kind == .linebreak, newTokens.last?.kind == .comment,
                    let previousNoCommentIndex = newTokens.lastIndex(where: { $0.kind != .comment && $0.kind != .indentation }) {
                    newTokens.insert(token, at: previousNoCommentIndex)
                } else {
                    newTokens.append(token)
                }
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
