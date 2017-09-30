
fun greet(name: String, day: String) {}
fun greet(name: String = "value", day: String, value: Int?) {}
fun method(param: String) : String {}
fun method(param: (Int) -> Unit) {}
fun findRestaurant(restaurantId: Int) : ServiceTask<Restaurant> {
    return NetworkRequestServiceTask<Restaurant>(networkSession = networkSession, endpoint = "restaurants/")
}
restaurantService.findRestaurant(restaurantId = restaurant.id, param = param)
