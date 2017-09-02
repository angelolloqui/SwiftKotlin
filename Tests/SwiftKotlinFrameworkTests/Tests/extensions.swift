extension Double {
    var km: Double { return self * 1000.0 }
    var m: Double { return self }
}
extension Double {
    func toKm() -> Double { return self * 1000.0 }
    func toMeter() -> Double { return self }
}
extension Double {
    static func toKm() -> Double { return self * 1000.0 }
    static var m: Double { return self }
}
