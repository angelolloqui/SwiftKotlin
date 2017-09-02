val Double.km: Double {
    return this * 1000.0
}
val Double.m: Double {
    return this
}
fun Double.toKm(): Double {
    return this * 1000.0
}
fun Double.toMeter(): Double {
    return this
}
fun Double.Companion.toKm(): Double {
    return this * 1000.0
}
val Double.Companion.m: Double {
    return this
}
