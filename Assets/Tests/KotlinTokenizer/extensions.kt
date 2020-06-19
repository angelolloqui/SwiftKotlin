internal val Double.km: Double
    get() = this * 1000.0
internal val Double.m: Double
    get() = this

private fun Double.toKm() : Double =
    this * 1000.0

internal fun Double.toMeter() : Double =
    this

fun Double.Companion.toKm() : Double =
    this * 1000.0
val Double.Companion.m: Double
    get() = this
