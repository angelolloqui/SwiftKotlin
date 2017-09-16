var Double.km: Double {
    return this * 1000.0
}
var Double.m: Double {
    return this
}
open fun Double.toKm() : Double {
    return this * 1000.0
}
fun Double.toMeter() : Double {
    return this
}
public fun Double.Companion.toKm() : Double {
    return this * 1000.0
}
public var Double.Companion.m: Double {
    return this
}
