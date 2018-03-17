
protocol Hello {
    var foo: String { get }
    var bar: String { get set }
}

class A {
    var myVar: String?
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

    var subject: TestSubject!

    lazy var players: [String] = {
        var temporaryPlayers = [String]()
        temporaryPlayers.append("John Doe")
        return temporaryPlayers
    }()
    private lazy var name: String = {() -> String in
        return "abc"
    }()
}

//class StepCounter {
//    var totalSteps: Int = 0 {
//        willSet(newTotalSteps) {
//            print("About to set totalSteps to \(newTotalSteps)")
//        }
//        didSet {
//            if totalSteps > oldValue  {
//                print("Added \(totalSteps - oldValue) steps")
//            }
//        }
//    }
//}

