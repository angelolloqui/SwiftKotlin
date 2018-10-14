enum class CompassPoint {
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
sealed class Barcode {
    data class upc(val v1: Int, val v2: Int, val v3: Int, val v4: Int) : Barcode()
    data class qrCode(val named: String) : Barcode()
    object empty : Barcode()
}
when (enumValue) {
    .resetPasswordSendEmail -> return (category: "ResetPassword", name: "sendEmail", label: null)
    .paymentSelectorOpen -> return (category: "PaymentSelector", name: "open", label: "${tenant.name} - ${option.duration}min")
}
when (exception) {
    .qrCode -> {
        val message = serverMessage
        if (message != null) {
            trackError(name = name, message = message)
        } else {
            trackError(name = name, message = R.string.localizable.network_error())
        }
    }
    else -> trackError(name = "generic", message = R.string.localizable.generic_error())
}
public sealed class SDKException : Error {
    object notFound : SDKException()
    object unauthorized : SDKException()
    data class network(val v1: HttpResponse, val v2: Error?) : SDKException()
}
