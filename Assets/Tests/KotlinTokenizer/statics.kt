
internal class A {
    companion object {
        var myBool = true
    }
}

internal class A {
    companion object {
        private var myBool = true
        var myNum = 3
        internal var myString = "string"
    }
}

internal class A {
    companion object {
        
        internal fun method() {}
    }
}

internal class A {
    companion object {
        
        internal fun method() {}
        
        internal fun create() : A? =
            null
        
        internal fun withParams(param: Int) : A? =
            null
    }
}

internal class A {
    companion object {
        internal var myBool = true
        
        internal fun method() {}
    }

    internal var name = "string"
    
    internal fun test() {}
}

internal data class A(internal var name = "string") {
    companion object {
        internal var myBool = true
        
        internal fun method() {}
    }

    
    internal fun test() {}
}
