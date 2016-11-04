
import Foundation


/// Find first differing character between two strings
///
/// :param: s1 First String
/// :param: s2 Second String
///
/// :returns: .DifferenceAtIndex(i) or .NoDifference
public func firstDifferenceBetweenStrings(_ s1: NSString, _ s2: NSString) -> FirstDifferenceResult {
    let len1 = s1.length
    let len2 = s2.length
    
    let lenMin = min(len1, len2)
    
    for i in 0..<lenMin {
        if s1.character(at: i) != s2.character(at: i) {
            return .DifferenceAtIndex(i)
        }
    }
    
    if len1 < len2 {
        return .DifferenceAtIndex(len1)
    }
    
    if len2 < len1 {
        return .DifferenceAtIndex(len2)
    }
    
    return .NoDifference
}


/// Create a formatted String representation of difference between strings
///
/// :param: s1 First string
/// :param: s2 Second string
///
/// :returns: a string, possibly containing significant whitespace and newlines
public func prettyFirstDifferenceBetweenStrings(_ s1: NSString, _ s2: NSString) -> String {
    let firstDifferenceResult = firstDifferenceBetweenStrings(s1, s2)
    return prettyDescriptionOfFirstDifferenceResult(firstDifferenceResult, s1, s2)
}


/// Create a formatted String representation of a FirstDifferenceResult for two strings
///
/// :param: firstDifferenceResult FirstDifferenceResult
/// :param: s1 First string used in generation of firstDifferenceResult
/// :param: s2 Second string used in generation of firstDifferenceResult
///
/// :returns: a printable string, possibly containing significant whitespace and newlines
public func prettyDescriptionOfFirstDifferenceResult(_ firstDifferenceResult: FirstDifferenceResult, _ s1: NSString, _ s2: NSString) -> String {
    
    func diffString(_ index: Int, _ s1: NSString, _ s2: NSString) -> String {
        let markerArrow = "👉"
        let ellipsis    = "…"
        /// Given a string and a range, return a string representing that substring.
        ///
        /// If the range starts at a position other than 0, an ellipsis
        /// will be included at the beginning.
        ///
        /// If the range ends before the actual end of the string,
        /// an ellipsis is added at the end.
        func windowSubstring(_ s: NSString, _ range: NSRange, isPrefix: Bool = false, isSuffix: Bool = false) -> String {
            let validRange = NSMakeRange(range.location, min(range.length, s.length - range.location))
            let substring = s.substring(with: validRange)
            
            let prefix = isPrefix && range.location > 0 ? ellipsis : ""
            let suffix = isSuffix && (s.length - range.location > range.length) ? ellipsis : ""
            
            return "\(prefix)\(substring)\(suffix)"
        }
        
        // Show this many characters before and after the first difference
        let windowPrefixLength = min(85, index)
        let windowSuffixLength = 60
        
        let prefix1 = windowSubstring(s1, NSMakeRange(index - windowPrefixLength, windowPrefixLength), isPrefix: true)
        let suffix1 = windowSubstring(s1, NSMakeRange(index, windowSuffixLength), isSuffix: true)
        
        let prefix2 = windowSubstring(s2, NSMakeRange(index - windowPrefixLength, windowPrefixLength), isPrefix: true)
        let suffix2 = windowSubstring(s2, NSMakeRange(index, windowSuffixLength), isSuffix: true)

        return "Difference at index \(index):\n------\n\(prefix1)\(markerArrow)\(suffix1)\n------\n\(prefix2)\(markerArrow)\(suffix2)\n------\n"
    }
    
    switch firstDifferenceResult {
    case .NoDifference:                 return "No difference"
    case .DifferenceAtIndex(let index): return diffString(index, s1, s2)
    }
}


/// Result type for firstDifferenceBetweenStrings()
public enum FirstDifferenceResult {
    /// Strings are identical
    case NoDifference
    
    /// Strings differ at the specified index.
    ///
    /// This could mean that characters at the specified index are different,
    /// or that one string is longer than the other
    case DifferenceAtIndex(Int)
}
