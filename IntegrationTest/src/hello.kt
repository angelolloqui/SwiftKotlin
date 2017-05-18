fun main(args: Array<String>) {

    val e = SomeError()
    println("ok: constructors ${e.message}")

    val e2 = SomeError(42)
    println("ok: constructor with anon param ${e2.message}")

    someFunc("anon param")

	conditionalFunc1()
	conditionalFunc2()
}

