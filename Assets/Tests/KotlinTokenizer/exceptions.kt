
internal val optA = try { obj.methodThrows() } catch (e: Throwable) { null }
internal val forceA = obj.methodThrows()

internal fun method() {
    obj.methodThrows()
}
