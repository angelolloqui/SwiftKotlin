val Double.km: Double
    get() = this * 1000.0
val Double.m: Double
    get() = this

open fun Double.toKm() : Double =
    this * 1000.0

fun Double.toMeter() : Double =
    this

public fun Double.Companion.toKm() : Double =
    this * 1000.0
public val Double.Companion.m: Double
    get() = this
