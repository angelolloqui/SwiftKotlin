//
//  NSRangeExtensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation


extension NSRange {
    
    func toIndexRange(in content: String) -> Range<String.Index> {
        let start = content.index(content.startIndex, offsetBy: location)
        let end = content.index(start, offsetBy: length)
        return Range<String.Index>(uncheckedBounds: (lower: start, upper: end))
    }
}


extension String {    
    func substring(with range: NSRange) -> String {
        return self.substring(with: range.toIndexRange(in: self))
    }
}
