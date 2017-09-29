
class A {
    var unwrapped: Object!
    var opt: Object?
}

let a = A()
a.unwrapped.action()
a.opt!.action()
