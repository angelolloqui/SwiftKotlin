
enum CompassPoint {
    case north
    case south
    case east
    case west
}

private enum Planet: Equatable {
    case mercury, venus, earth
    case mars, jupiter, saturn, uranus, neptune
}

enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(named: String)
    case empty
}

public enum SDKException: Error {
    case notFound
    case unauthorized
    case network(HttpResponse, Error?)
}

public enum PaymentMethodType: String, Equatable {
    case direct = "DIRECT",  creditCard = "CREDIT_CARD"
}

enum AnimationLength {
    case short
    case long
    var duration: Double {
        switch self {
        case AnimationLength.short:
            return 2
        case .long:
            return 5.0
        }
    }

    func getDuration() -> Double {
        return self.duration
    }
}

enum AnimationLengthAdvanced: Equatable {
    case short
    case long
    case custom(Double)

    var duration: Double {
        switch self {
        case .short:
            return 2
        case .long:
            return 5.0
        case .custom(let duration):
            return duration
        }
    }

    func getDuration() -> Double {
        return self.duration
    }
}

// Usage
switch enumValue {
case .resetPasswordSendEmail:
    return (category: "ResetPassword", name: "sendEmail", label: nil)
case .paymentSelectorOpen(_, let tenant, _, let option):
    return (category: "PaymentSelector", name: "open", label: "\(tenant.name) - \(option.duration)min")
}

switch exception {
case .qrCode(_):
    if let message = serverMessage {
        trackError(name: name, message: message)
    } else {
        trackError(name: name, message: R.string.localizable.network_error())
    }
default:
    trackError(name: "generic", message: R.string.localizable.generic_error())
}

switch planets {
case .mars, .earth, .venus:
    habitable = true
default:
    habitable = false

}

let nb = 42
switch nb {
    case 0: print("zero")
    case 1, 2, 3: print("low numbers")
    case 4...7, 8, 9: print("single digit")
    case 10: print("double digits")
    case 11...99: print("double digits")
    case 100...999: print("triple digits")
    default: print("four or more digits")
}
