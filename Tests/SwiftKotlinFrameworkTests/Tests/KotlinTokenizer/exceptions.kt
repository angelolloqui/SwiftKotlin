
val optA = try { obj.methodThrows() } catch (e: Throwable) { null }
val forceA = obj.methodThrows()

fun method() {
    obj.methodThrows()
}
