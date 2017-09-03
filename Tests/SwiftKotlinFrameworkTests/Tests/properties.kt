class A {
    val stateObservable1: Observable<RestaurantsListState>
        get() = state.asObservable()
    val stateObservable2: Observable<RestaurantsListState>
        get() = state.asObservable()
    val stateObservable3: Observable<RestaurantsListState>
        get() {
            NSLog("Multiple statements")
            return state.asObservable()
        }
    var center: Point {
        get() = Point(x: centerX, y: centerY)
        set(newValue) {
            origin.x = newValue.x - 100
        }
    }
    var numberOfEdits = 0
        private set
    lateinit var subject: TestSubject
}
protocol Hello {
    val foo: String
    var bar: String
}
