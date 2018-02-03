
interface Hello {
    val foo: String
    var bar: String
}

class A {
    val stateObservable1: Observable<RestaurantsListState>
        get() = state.asObservable()
    val stateObservable2: Observable<RestaurantsListState>
        get() {
            return state.asObservable()
        }
    val stateObservable3: Observable<RestaurantsListState>
        get() {
            NSLog("Multiple statements")
            return state.asObservable()
        }
    var center: Point
        get() {
            return Point(x = centerX, y = centerY)
        }
        set(newValue) {
            origin.x = newValue.x - 100
        }
    var top: Point
        get() {
            return Point(x = topX, y = topY)
        }
        set(val) {
            origin.y = 0
            origin.x = val.x
        }
    lateinit var subject: TestSubject
}
