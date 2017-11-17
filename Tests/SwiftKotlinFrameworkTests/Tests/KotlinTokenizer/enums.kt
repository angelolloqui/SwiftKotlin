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
