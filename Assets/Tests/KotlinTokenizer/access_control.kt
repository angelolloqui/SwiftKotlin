internal class ImplicitInternalClass {
    private val privateVar: Int = 1
    internal val implicitInternalVar: Int = 1
    internal val explicitInternalVar: Int = 1

    private class PrivateClass {
        private var privateVar: Int = 1
        var implicitPrivateVar: Int = 1

        class InheritedAccess {
            private var privateVar: Int = 1
            var implicitPrivateVar: Int = 1

            fun inheritedAccessFunc() {}
        }

        fun inheritedAccessFunc() {}
    }

    internal fun implicitInternalFunc() {}

    internal fun internalFunc() {}

    private fun privateFunc() {}
}

class PublicClass {
    private val privateVar: Int = 1
    internal val implicitInternalVar: Int = 1
    internal val explicitInternalVar: Int = 1
    val publicVar: Int = 1

    internal class InheritedAccess {}

    internal fun implicitInternalFunc() {}

    internal fun internalFunc() {}

    private fun privateFunc() {}

    fun publicFunc() {}
}

private class PrivateClass {

    class InheritedAccess {}
}

data class publicStruct(
    var publicVar: String,
    internal var internalVar: String,
    private var privateVar: String) {}

internal data class internalStruct(
    internal var internalVar: String,
    private var privateVar: String) {}

interface publicProtocol {}
enum class publicEnum {
    a
}
internal enum class internalEnum {
    a
}

internal fun implicitInternalFunc() {
    val internalVariable = 1
}

internal fun internalFunc() {
    val internalVariable = 1
}

private fun privateFunc() {
    val internalVariable = 1
}

fun publicFunc() {
    val internalVariable = 1
}
