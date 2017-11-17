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
