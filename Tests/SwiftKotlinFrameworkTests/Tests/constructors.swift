
open class ClassA {
    public init() {}
}

open class ClassB: ClassA {
	let message: String
	let cause: String

	public init(message: String, cause: String) {
		self.message = message
		self.cause = cause
        super.init()
	}

    public convenience init(_ cause: String) {
        self.init(message: "", cuase: cause)
    }
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
