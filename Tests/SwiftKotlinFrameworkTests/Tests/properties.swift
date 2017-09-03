class A {
    var stateObservable1: Observable<RestaurantsListState> { return state.asObservable() }
    var stateObservable2: Observable<RestaurantsListState> {
        get {
            return state.asObservable()
        }
    }
    var stateObservable2: Observable<RestaurantsListState> {
        NSLog("Multiple statements")
        return state.asObservable()
    }
    var center1: Point {
        set(newValue) {
            origin.x = newValue.x - 100
        }
    }
    var center2: Point {
        set {
            origin.x = newValue.x - 100
        }
    }
    var center3: Point {
        get {
            return Point(x: centerX, y: centerY)
        }
        set {
            origin.x = newValue.x - 100
        }
    }

    private(set) var numberOfEdits = 0

    var subject: TestSubject!
}

protocol Hello {
    var foo: String { get }
    var bar: String { get set }
}
