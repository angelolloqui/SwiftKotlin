
let optA = try? obj.methodThrows()
let forceA = try! obj.methodThrows()

func method() throws {
    try obj.methodThrows()
}
