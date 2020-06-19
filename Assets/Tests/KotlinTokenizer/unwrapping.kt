internal class A {
    lateinit internal var unwrapped: Object
    internal var opt: Object? = null
}
internal val a = A()
a.unwrapped.action()
a.opt!!.action()
