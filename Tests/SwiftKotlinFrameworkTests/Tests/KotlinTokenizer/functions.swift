
func greet(_ name: String, _ day: String) {}
func greet(aName name: String = "value", day: String, other value: Int?) {}
func method(param: String) -> String {}
func method(param: (Int) -> Void) {}

func findRestaurant(restaurantId: Int) -> ServiceTask<Restaurant> {
    return NetworkRequestServiceTask<Restaurant>(
        networkSession: networkSession,
        endpoint: "restaurants/")
}

restaurantService.findRestaurant(restaurantId: restaurant.id, param: param)
