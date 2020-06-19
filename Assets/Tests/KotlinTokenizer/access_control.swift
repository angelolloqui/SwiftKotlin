
class ImplicitInternalClass {
    private let privateVar: Int = 1
    let implicitInternalVar: Int = 1
    internal let explicitInternalVar: Int = 1

    private class PrivateClass {
        private var privateVar: Int = 1
        var implicitPrivateVar: Int = 1

        class InheritedAccess {
            private var privateVar: Int = 1
            var implicitPrivateVar: Int = 1

            func inheritedAccessFunc() {}
        }

        func inheritedAccessFunc() {}
    }

    func implicitInternalFunc() {}
    internal func internalFunc() {}
    private func privateFunc() {}
}

public class PublicClass {
    private let privateVar: Int = 1
    let implicitInternalVar: Int = 1
    internal let explicitInternalVar: Int = 1
    public let publicVar: Int = 1

    class InheritedAccess {

    }

    func implicitInternalFunc() {}
    internal func internalFunc() {}
    private func privateFunc() {}
    public func publicFunc() {}
}

private class PrivateClass {
    class InheritedAccess {

    }
}

public struct publicStruct {
    public var publicVar: String
    var internalVar: String
    private var privateVar: String
}

struct internalStruct {
    var internalVar: String
    private var privateVar: String
}

public protocol publicProtocol {
}

public enum publicEnum {
    case a
}
enum internalEnum {
    case a
}

func implicitInternalFunc() {
    let internalVariable = 1
}
internal func internalFunc() {
    let internalVariable = 1
}
private func privateFunc() {
    let internalVariable = 1
}
public func publicFunc() {
    let internalVariable = 1
}
