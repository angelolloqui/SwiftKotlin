
open class ClassA {
    public init() {}
}

open class ClassB: ClassA {
	public let message: String
	private let cause: String

	public init(message: String, cause: String) {
		self.message = message
		self.cause = cause
        super.init()
	}

    public convenience init(_ cause: String) {
        self.init(message: "", cuase: cause)
    }

    private func privateMethod() {}
    internal func internalMethod() {}
    func implicitInternalMethod()
    public func publicMethod() {}
}

open class ClassC: ClassB {
    public init() {
        super.init(message: "message", cause: "cause")
    }
}

let obj1 = ClassA()
let obj2 = ClassB(message: "message", cause: "a cause")
let obj3 = ClassB("a cause")
let obj4 = ClassC()
