
fun greet(name: String, day: String) {}

fun greet(name: String = "value", day: String, value: Int?) {}

fun method(param: String) : String {}

fun method(param: (Int) -> Unit) {}

fun findRestaurant(restaurantId: Int) : ServiceTask<Restaurant> =
    NetworkRequestServiceTask<Restaurant>(networkSession = networkSession, endpoint = "restaurants/")
restaurantService.findRestaurant(restaurantId = restaurant.id, param = param)

fun tokenize(codeBlock: String?) : List<String> {
    val statement = codeBlock ?: return listOf()
    return someOtherMethod(statement = statement)
}

public fun <T> whenAll(promises: List<Promise<T>>) : Promise<List<T>> =
    Promise<T>()

fun sumOf(vararg numbers: Int) : Int {
    var sum = 0
    for (number in numbers) {
        sum += number
    }
    return sum
}
sumOf(42, 597, 12)
