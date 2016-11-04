//
//  TestExtensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 01/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation
import XCTest

extension Transformer {
    func translate(content: String) throws -> String {
        let tokens =  tokenize(content)
        let formatter = Formatter(tokens)
        try self.transform(formatter: formatter)
        return formatter.tokens.reduce("", { $0 + $1.string })
    }
}


func AssertTranslateEquals(_ translate: String?, _ expected: String) {
    guard let translate = translate else {
        XCTFail("Translation failed")
        return
    }
    
    if translate != expected {
        //Find text difference
        let difference = prettyFirstDifferenceBetweenStrings(translate as NSString, expected as NSString)
        XCTFail(difference)
    }
}


