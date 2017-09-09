
class A {
    companion object {
        public var myBool = true
    }
}
class A {
    companion object {
        private var myBool = true
        var myNum = 3
        var myString = "string"
    }
}
class A {
    companion object {
        fun method() {}
    }
}
class A {
    companion object {
        fun method() {}
        fun create() : A? {
            return null
        }
        fun withParams(param: Int) : A? {
            return null
        }
    }
}
class A {
    companion object {
        var myBool = true
        fun method() {}
    }

    var name = "string"
    fun test() {}
}
data class A {
    companion object {
        var myBool = true
        fun method() {}
    }

    var name = "string"
    fun test() {}
}
