open class ClassA {

    constructor() {}
}

open class ClassB: ClassA {
    val message: String
    private val cause: String

    constructor(message: String, cause: String) : super() {
        this.message = message
        this.cause = cause
    }

    constructor(cause: String) : this(message = "", cuase = cause) {}

    private fun privateMethod() {}

    internal fun internalMethod() {}

    fun implicitInternalMethod()

    fun publicMethod() {}
}

open class ClassC: ClassB {

    constructor() : super(message = "message", cause = "cause") {}
}
internal val obj1 = ClassA()
internal val obj2 = ClassB(message = "message", cause = "a cause")
internal val obj3 = ClassB("a cause")
internal val obj4 = ClassC()
