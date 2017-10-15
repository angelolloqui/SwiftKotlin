
import Foundation

/// Find first differing character between two strings
///
/// :param: s1 First String
/// :param: s2 Second String
///
/// :returns: .DifferenceAtIndex(i) or .NoDifference
public func firstDifferenceBetweenStrings(_ s1: String, _ s2: String) -> FirstDifferenceResult {
    let len1 = s1.characters.count
    let len2 = s2.characters.count

    let lenMin = min(len1, len2)

    for i in 0..<lenMin {
        if s1.characters[s1.index(s1.startIndex, offsetBy: i)] != s2.characters[s2.index(s2.startIndex, offsetBy: i)] {
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
public func prettyFirstDifferenceBetweenStrings(_ s1: String, _ s2: String) -> String {
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
public func prettyDescriptionOfFirstDifferenceResult(
    _ firstDifferenceResult: FirstDifferenceResult,
    _ s1: String,
    _ s2: String) -> String {

    func diffString(_ index: Int, _ s1: String, _ s2: String) -> String {
        let markerArrow: Character = "👉"

        var string1 = s1
        string1.insert(markerArrow, at: string1.index(string1.startIndex, offsetBy: index))

        var string2 = s2
        string2.insert(markerArrow, at: string2.index(string2.startIndex, offsetBy: index))

        return "Difference at index \(index):\n------ Result: \n\(string1)\n------ Expected:\n\(string2)\n------\n"
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
