//
//  UIKitTransformPlugin.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 17/05/2020.
//

import Foundation
import Transform
import AST

public class UIKitTransformPlugin: TokenTransformPlugin {
    public var name: String {
        return "UIKit transformations"
    }

    public var description: String {
        return "Transforms classes like UIView, UILabel,... to their Android counterpart"
    }

    public init() {}

    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = [Token]()

        for token in tokens {
            if token.kind == .identifier, let mapping = classMappings[token.value], let node = token.node {
                newTokens.append(node.newToken(.identifier, mapping))
            } else {
                newTokens.append(token)
            }
        }
        return newTokens
    }

    let classMappings = [
        "UIView": "View",
        "UILabel": "TextView",
        "UITextField": "EditText",
        "UIImageView": "ImageView",
        "UIButton": "Button",
        "UITableView": "RecyclerView",
        "UIStackView": "LinearLayout",
        "UIScrollView": "ScrollView",
        "UISwitch": "Switch",
        "IBOutlet": "BindView()",
        "IBAction": "OnClick()"
    ]

}
