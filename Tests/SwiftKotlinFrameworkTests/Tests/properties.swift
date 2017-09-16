class A {
    var stateObservable1: Observable<RestaurantsListState> { return state.asObservable() }
    var stateObservable2: Observable<RestaurantsListState> {
        get {
            return state.asObservable()
        }
    }
    var stateObservable3: Observable<RestaurantsListState> {
        NSLog("Multiple statements")
        return state.asObservable()
    }
    
    var center: Point {
        get {
            return Point(x: centerX, y: centerY)
        }
        set {
            origin.x = newValue.x - 100
        }
    }

    var top: Point {
        get {
            return Point(x: topX, y: topY)
        }
        set(val) {
            origin.y = 0
            origin.x = val.x
        }
    }

    private(set) var numberOfEdits = 0

    var subject: TestSubject!
}

protocol Hello {
    var foo: String { get }
    var bar: String { get set }
}
