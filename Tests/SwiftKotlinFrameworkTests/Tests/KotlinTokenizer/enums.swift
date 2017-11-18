
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

// Usage
switch enumValue {
case .resetPasswordSendEmail:
    return (category: "ResetPassword", name: "sendEmail", label: nil)
case .paymentSelectorOpen(_, let tenant, _, let option):
    return (category: "PaymentSelector", name: "open", label: "\(tenant.name) - \(option.duration)min")
}
