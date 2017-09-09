
class A {
    public static var myBool = true
}

class A {
    static private var myBool = true
    static var myNum = 3
    static var myString = "string"
}

class A {
    static func method() {}
}

class A {
    static func method() {}
    static func create() -> A? { return nil }
    static func withParams(param: Int) -> A? { return nil }
}

class A {
    var name = "string"
    static var myBool = true
    static func method() {}
    func test() {}
}

struct A {
    var name = "string"
    static var myBool = true
    static func method() {}
    func test() {}
}
