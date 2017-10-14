class A {
    lateinit var unwrapped: Object
    var opt: Object?
}
val a = A()
a.unwrapped.action()
a.opt!!.action()
