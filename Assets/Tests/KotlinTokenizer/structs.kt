
internal data class Data(internal var text: String) {}

data class Person(
    internal val name: String,
    internal val surname: String,
    internal var age: Int) {
    
    internal fun eat() {}

    private fun incrementAge() {}
}

internal data class User(
    var id: Int? = 0,
    var name: String? = null,
    var content: Content): Codable {
    
    data class Content(val text: String) {}
}
