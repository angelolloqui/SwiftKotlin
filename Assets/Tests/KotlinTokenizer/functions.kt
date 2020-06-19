
internal fun greet(name: String, day: String) {}

internal fun greet(name: String = "value", day: String, value: Int?) {}

internal fun method(param: String) : String {}

internal fun method(param: (Int) -> Unit) {}

internal fun findRestaurant(restaurantId: Int) : ServiceTask<Restaurant> =
    NetworkRequestServiceTask<Restaurant>(networkSession = networkSession, endpoint = "restaurants/")
restaurantService.findRestaurant(restaurantId = restaurant.id, param = param)

internal fun tokenize(codeBlock: String?) : List<String> {
    val statement = codeBlock ?: return listOf()
    return someOtherMethod(statement = statement)
}

fun <T> whenAll(promises: List<Promise<T>>) : Promise<List<T>> =
    Promise<T>()

fun <T> whenAny(promises: List<Promise<T>>) : Promise<List<T>> =
    Promise<T>()

internal fun sumOf(vararg numbers: Int) : Int {
    var sum = 0
    for (number in numbers) {
        sum += number
    }
    return sum
}
sumOf(42, 597, 12)
