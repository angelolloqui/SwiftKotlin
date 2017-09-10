
open class ClassA {
    public constructor() {}
}
open class ClassB: ClassA {
	val message: String
	val cause: String
    public constructor(message: String, cause: String) : super() {
		this.message = message
		this.cause = cause
	}
    public constructor(cause: String) : this(message = "", cuase = cause) {
    }
}
open class ClassC: ClassB {
    public constructor() : super(message = "message", cause = "cause") {
    }
}
val obj1 = ClassA()
val obj2 = ClassB(message = "message", cause = "a cause")
val obj3 = ClassB("a cause")
val obj4 = ClassC()
