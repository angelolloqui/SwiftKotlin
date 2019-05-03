//
//  EnumDeclaration+Operations.swift
//  AST
//
//  Created by Angel Luis Garcia on 03/05/2019.
//

import Foundation
import AST
import Transform

extension EnumDeclaration.Member {
    var rawValueStyleEnumCase: EnumDeclaration.RawValueStyleEnumCase? {
        switch self {
        case .rawValue(let rawValueStyleEnumCase):
            return rawValueStyleEnumCase
        default:
            return nil
        }
    }
}

extension KotlinTokenizer {

    func tokenizeNoValueEnum(declaration: EnumDeclaration, simpleCases: [AST.EnumDeclaration.UnionStyleEnumCase.Case]) -> [Token] {
        let space = declaration.newToken(.space, " ")
        let lineBreak = declaration.newToken(.linebreak, "\n")
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "enum")],
            [declaration.newToken(.keyword, "class")],
            [declaration.newToken(.identifier, declaration.name)],
            ].joined(token: space)
        let otherMemberTokens = declaration.members.filter { $0.unionStyleEnumCase == nil && $0.rawValueStyleEnumCase == nil }
            .map { tokenize($0, node: declaration) }
            .joined(token: lineBreak)
            .prefix(with: lineBreak)
        let membersTokens = simpleCases.map { c in
            return [c.newToken(.identifier, c.name, declaration)]
            }.joined(tokens: [
                declaration.newToken(.delimiter, ","),
                lineBreak
                ])

        return headTokens +
            [space, declaration.newToken(.startOfScope, "{"), lineBreak] +
            indent(membersTokens) +
            indent(otherMemberTokens).prefix(with: lineBreak) +
            [lineBreak, declaration.newToken(.endOfScope, "}")]
    }

    func tokenizeSimpleValueEnum(declaration: EnumDeclaration, simpleCases: [AST.EnumDeclaration.UnionStyleEnumCase.Case]) -> [Token] {
        let space = declaration.newToken(.space, " ")
        let lineBreak = declaration.newToken(.linebreak, "\n")
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let inheritanceTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let inheritanceType = declaration.typeInheritanceClause!.typeInheritanceList.first!
        let otherInheritances = declaration.typeInheritanceClause!.typeInheritanceList.filter { $0 !== inheritanceType }
        let rawCases = declaration.members.compactMap { $0.rawValueStyleEnumCase }

        let initTokens = [
            declaration.newToken(.startOfScope, "("),
            declaration.newToken(.keyword, "val"),
            space,
            declaration.newToken(.identifier, "rawValue"),
            declaration.newToken(.delimiter, ":"),
            space
            ] + tokenize(inheritanceType, node: declaration) +
            [declaration.newToken(.endOfScope, ")")]
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "enum")],
            [declaration.newToken(.keyword, "class")],
            [declaration.newToken(.identifier, declaration.name)],
            initTokens,
            otherInheritances.isEmpty ? [] : [declaration.newToken(.delimiter, ":")],
            otherInheritances.map { tokenize($0, node: declaration) }.joined(token: declaration.newToken(.delimiter, ", "))
        ].joined(token: space)

        let typeToken = inheritanceTokens.first(where: { $0.kind == .identifier })!
        let comps: [Token]
        if simpleCases.count > 0 {
            comps = getSimpleAssignments(simpleCases: simpleCases, declaration: declaration, typeToken: typeToken)
        } else {
            comps = getAssignments(rawCases: rawCases, declaration: declaration, typeToken: typeToken)
        }
        let initFromRawTokens = [lineBreak] + indent(makeInitEnumFromRawFunc(declaration: declaration, typeToken:typeToken))
        let otherMemberTokens = declaration.members.filter { $0.unionStyleEnumCase == nil && $0.rawValueStyleEnumCase == nil }
            .map { tokenize($0, node: declaration) }
            .joined(token: lineBreak)
            .prefix(with: lineBreak)
        let bodyTokens = [space, declaration.newToken(.startOfScope, "{"), lineBreak] +
            indent(comps) + [declaration.newToken(.delimiter, ";"), lineBreak] +
            initFromRawTokens +
            indent(otherMemberTokens).prefix(with: lineBreak) +
            [lineBreak, declaration.newToken(.endOfScope, "}")]
        return headTokens + bodyTokens
    }

    func tokenizeSealedClassEnum(declaration: EnumDeclaration, simpleCases: [AST.EnumDeclaration.UnionStyleEnumCase.Case]) -> [Token] {
        let space = declaration.newToken(.space, " ")
        let lineBreak = declaration.newToken(.linebreak, "\n")
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) } ?? []
        let inheritanceTokens = declaration.typeInheritanceClause.map { tokenize($0, node: declaration) } ?? []
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "sealed")],
            [declaration.newToken(.keyword, "class")],
            [declaration.newToken(.identifier, declaration.name)],
            inheritanceTokens
            ].joined(token: space)

        let membersTokens = simpleCases.map { c in
            var tokenSections: [[Token]]
            if let tuple = c.tuple {
                tokenSections = [
                    [c.newToken(.keyword, "data", declaration)],
                    [c.newToken(.keyword, "class", declaration)],
                    [c.newToken(.identifier, c.name, declaration)] + tokenize(tuple, node: declaration)
                ]
            } else {
                tokenSections = [
                    [c.newToken(.keyword, "object", declaration)],
                    [c.newToken(.identifier, c.name, declaration)]
                ]
            }
            tokenSections += [
                [c.newToken(.symbol, ":", declaration)],
                [c.newToken(.identifier, declaration.name, declaration), c.newToken(.startOfScope, "(", declaration), c.newToken(.endOfScope, ")", declaration)]
            ]
            return tokenSections.joined(token: space)
            }.joined(token: lineBreak)

        let otherMemberTokens = declaration.members.filter { $0.unionStyleEnumCase == nil && $0.rawValueStyleEnumCase == nil }
            .map { tokenize($0, node: declaration) }
            .joined(token: lineBreak)
            .prefix(with: lineBreak)

        return headTokens +
            [space, declaration.newToken(.startOfScope, "{"), lineBreak] +
            indent(membersTokens) +
            indent(otherMemberTokens).prefix(with: lineBreak) +
            [lineBreak, declaration.newToken(.endOfScope, "}")]
    }
}

private extension KotlinTokenizer {

    func makeInitEnumFromRawFunc(declaration d: EnumDeclaration, typeToken: Token) -> [Token] {
        let name = d.newToken(.identifier, d.name)
        let space = d.newToken(.space, " ")
        let lineBreak = d.newToken(.linebreak, "\n")
        return [
            d.newToken(.keyword, "companion"),
            space,
            d.newToken(.keyword, "object"),
            space,
            d.newToken(.startOfScope, "{"),
            lineBreak ] +
            indent([
                d.newToken(.keyword, "operator"),
                space,
                d.newToken(.keyword, "fun"),
                space,
                d.newToken(.keyword, "invoke"),
                d.newToken(.startOfScope, "("),
                d.newToken(.identifier, "rawValue"),
                d.newToken(.delimiter, ":"),
                space,
                typeToken,
                d.newToken(.endOfScope, ")"),
                space,
                d.newToken(.symbol, "="),
                space,
                name,
                d.newToken(.delimiter, "."),
                d.newToken(.identifier, "values"),
                d.newToken(.startOfScope, "("),
                d.newToken(.endOfScope, ")"),
                d.newToken(.delimiter, "."),
                d.newToken(.identifier, "firstOrNull"),
                space,
                d.newToken(.startOfScope, "{"),
                space,
                d.newToken(.identifier, "it"),
                d.newToken(.delimiter, "."),
                d.newToken(.identifier, "rawValue"),
                space,
                d.newToken(.symbol, "=="),
                space,
                d.newToken(.identifier, "rawValue"),
                space,
                d.newToken(.endOfScope, "}")
                ]) + [
                    lineBreak,
                    d.newToken(.endOfScope, "}")
        ]
    }


    // these two methods below allow getting simple, non type enums and single-type enums and outputing their values.
    func getAssignments(rawCases: [AST.EnumDeclaration.RawValueStyleEnumCase], declaration: EnumDeclaration, typeToken: Token) -> [Token] {
        let space = declaration.newToken(.space, " ")
        var acomps = [[Token]]()
        var intStart = 0
        for r in rawCases {
            for c in r.cases {
                var set = space // just set it to something
                if (c.assignment == nil) {
                    switch typeToken.value {
                    case "String":
                        set = declaration.newToken(.string, "\"\(c.name)\"")
                    default: // Int
                        set = declaration.newToken(.number, "\(intStart)")
                        intStart += 1
                    }
                } else {
                    switch c.assignment! {
                    case .string(let s):
                        set = declaration.newToken(.string, "\"\(s)\"")
                    case .floatingPoint(let f):
                        set = declaration.newToken(.number, "\(f)")
                        intStart = Int(f) + 1
                    case .boolean(let b):
                        set = declaration.newToken(.keyword, "\(b)")
                    case .integer(let i):
                        set = declaration.newToken(.number, "\(i)")
                        intStart = i + 1
                    }
                }
                let c = [
                    declaration.newToken(.identifier, c.name),
                    declaration.newToken(.startOfScope, "("),
                    set,
                    declaration.newToken(.endOfScope, ")")
                ]
                acomps.append(c)
            }
        }
        return acomps.joined(tokens: [ declaration.newToken(.delimiter, ","), space ])
    }

    func getSimpleAssignments(simpleCases: [AST.EnumDeclaration.UnionStyleEnumCase.Case], declaration: EnumDeclaration, typeToken: Token) -> [Token] {
        let space = declaration.newToken(.space, " ")
        var acomps = [[Token]]()
        var intStart = 0
        var boolStart = false
        for s in simpleCases {
            var set = space // hack to set it to space to start
            switch typeToken.value {
            case "Bool":
                set = declaration.newToken(.keyword, "\(boolStart)")
                boolStart = !boolStart
            case "String":
                set = declaration.newToken(.string, "\"\(s.name)\"")
            default:
                set = declaration.newToken(.number, "\(intStart)")
                intStart += 1
            }
            let comp = [
                declaration.newToken(.identifier, s.name),
                declaration.newToken(.startOfScope, "("),
                set,
                declaration.newToken(.endOfScope, ")")
            ]
            acomps.append(comp)
        }
        return acomps.joined(tokens: [ declaration.newToken(.delimiter, ","), space ])
    }
}
