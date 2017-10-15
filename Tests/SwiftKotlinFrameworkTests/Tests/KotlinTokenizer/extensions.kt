val Double.km: Double
    get() {
        return this * 1000.0
    }
val Double.m: Double
    get() {
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
public val Double.Companion.m: Double
    get() {
        return this
    }
