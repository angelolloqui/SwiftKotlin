class A {
    lateinit var unwrapped: Object
    var opt: Object? = null
}
val a = A()
a.unwrapped.action()
a.opt!!.action()
