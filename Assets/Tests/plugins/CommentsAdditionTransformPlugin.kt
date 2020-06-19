//
//  Header comments
//  Multiple lines together
//
//  Created by Angel Garcia on 14/10/2017.
//

internal class MyClass {
    //Public properties
    internal var a: Int? = null
    internal var b: String? = null

    //Public method
    internal fun aMethod() {
        // A comment inside aMethod
        b = "method run"
        b = b + "more"
    }

    /*
    Multiline comments
    are also supported
    */
    internal fun anotherMethod() {
        val a = this.a
        if (a != null) {
            // Inside if
            this.a = a + 1
        } else {
            // Inside else
            this.a = 1
        }
    }
}

// Other comments before structs
internal data class MyStruct {}

