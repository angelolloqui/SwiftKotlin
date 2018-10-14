
interface Hello {
    val foo: String
    var bar: String
}

class A {
    var myVar: String? = null
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
    val players: List<String> by lazy {
        var temporaryPlayers = listOf(String)()
        temporaryPlayers.append("John Doe")
        temporaryPlayers
    }
    private val name: String by lazy {   -> 
        "abc"
    }
    var isLocating = false
        set(newValue) {
            val oldValue = field
            field = newValue
            delegate.set(isLocating = isLocating)
        }
}

data class Rect(
    var origin = Point(),
    var size = Size()) {
    var center: Point
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

class StepCounter {
    var totalSteps: Int = 0
        set(newTotalSteps) {
            val oldValue = field
            print("About to set totalSteps to ${newTotalSteps}")
            field = newTotalSteps
            if (totalSteps > oldValue) {
                print("Added ${totalSteps - oldValue} steps")
            }
        }
}
