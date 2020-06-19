
internal interface Hello {
    val foo: String
    var bar: String
}

internal class A {
    internal var myVar: String? = null
    internal val stateObservable1: Observable<RestaurantsListState>
        get() = state.asObservable()
    internal val stateObservable2: Observable<RestaurantsListState>
        get() = state.asObservable()
    internal val stateObservable3: Observable<RestaurantsListState>
        get() = state.asObservable()
    internal val stateObservable4: Observable<RestaurantsListState>
        get() {
            NSLog("Multiple statements")
            return state.asObservable()
        }
    internal var center: Point
        get() = Point(x = centerX, y = centerY)
        set(newValue) {
            origin.x = newValue.x - 100
        }
    internal var top: Point
        get() = Point(x = topX, y = topY)        
        set(val) {
            origin.y = 0
            origin.x = val.x
        }
    lateinit internal var subject: TestSubject
    internal val players: List<String> by lazy {
        var temporaryPlayers = listOf<String>()
        temporaryPlayers.append("John Doe")
        temporaryPlayers
    }
    private val name: String by lazy {   -> 
        "abc"
    }
    internal var isLocating = false
        set(newValue) {
            val oldValue = field
            field = newValue
            delegate.set(isLocating = isLocating)
        }
    var anotherName: String? = null
        private set
    var anotherNameWithDidSet: String = "a value"
        private set(newValue) {
            field = newValue
        }
    internal val myVar: String
        get() {
            if (a == 5) {
                return "test"
            } else {
                return "b"
            }
        }
}

internal data class Rect(
    internal var origin = Point(),
    internal var size = Size()) {
    internal var center: Point
        get() {
            val centerX = origin.x + (size.width / 2)
            val centerY = origin.y + (size.height / 2)
            return Point(x = centerX, y = centerY)
        }
        set(newCenter) {
            origin.x = newCenter.x - (size.width / 2)
            origin.y = newCenter.y - (size.height / 2)
        }
}

internal class StepCounter {
    internal var totalSteps: Int = 0
        set(newTotalSteps) {
            val oldValue = field
            print("About to set totalSteps to ${newTotalSteps}")
            field = newTotalSteps
            if (totalSteps > oldValue) {
                print("Added ${totalSteps - oldValue} steps")
            }
        }
}
