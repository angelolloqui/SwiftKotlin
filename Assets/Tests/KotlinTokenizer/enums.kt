internal enum class CompassPoint {
    north,
    south,
    east,
    west
}
private enum class Planet {
    mercury,
    venus,
    earth,
    mars,
    jupiter,
    saturn,
    uranus,
    neptune
}
internal sealed class Barcode {
    data class upc(val v1: Int, val v2: Int, val v3: Int, val v4: Int) : Barcode()
    data class qrCode(val named: String) : Barcode()
    object empty : Barcode()
}
sealed class SDKException : Error {
    object notFound : SDKException()
    object unauthorized : SDKException()
    data class network(val v1: HttpResponse, val v2: Error?) : SDKException()
}
enum class PaymentMethodType (val rawValue: String) : Equatable {
    direct("DIRECT"), creditCard("CREDIT_CARD");

    companion object {
        operator fun invoke(rawValue: String) = PaymentMethodType.values().firstOrNull { it.rawValue == rawValue }
    }
}
internal enum class AnimationLength {
    short,
    long

    internal val duration: Double
        get() {
            when (this) {
                AnimationLength.short -> return 2
                long -> return 5.0
            }
        }

    internal fun getDuration() : Double =
        this.duration
}
internal sealed class AnimationLengthAdvanced {
    object short : AnimationLengthAdvanced()
    object long : AnimationLengthAdvanced()
    data class custom(val v1: Double) : AnimationLengthAdvanced()

    internal val duration: Double
        get() {
            when (this) {
                short -> return 2
                long -> return 5.0
                is custom -> return duration
            }
        }

    internal fun getDuration() : Double =
        this.duration
}
when (enumValue) {
    resetPasswordSendEmail -> return (category: "ResetPassword", name: "sendEmail", label: null)
    is paymentSelectorOpen -> return (category: "PaymentSelector", name: "open", label: "${tenant.name} - ${option.duration}min")
}
when (exception) {
    is qrCode -> {
        val message = serverMessage
        if (message != null) {
            trackError(name = name, message = message)
        } else {
            trackError(name = name, message = R.string.localizable.network_error())
        }
    }
    else -> trackError(name = "generic", message = R.string.localizable.generic_error())
}
when (planets) {
    mars, earth, venus -> habitable = true
    else -> habitable = false
}
internal val nb = 42
when (nb) {
    0 -> print("zero")
    1, 2, 3 -> print("low numbers")
    in 4 .. 7, 8, 9 -> print("single digit")
    10 -> print("double digits")
    in 11 .. 99 -> print("double digits")
    in 100 .. 999 -> print("triple digits")
    else -> print("four or more digits")
}
