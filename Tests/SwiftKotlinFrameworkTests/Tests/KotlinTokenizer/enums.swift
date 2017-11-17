
enum CompassPoint {
    case north
    case south
    case east
    case west
}

private enum Planet {
    case mercury, venus, earth
    case mars, jupiter, saturn, uranus, neptune
}

enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(named: String)
    case empty
}
