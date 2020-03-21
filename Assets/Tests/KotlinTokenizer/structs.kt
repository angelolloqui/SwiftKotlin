
data class Data(var text: String) {}

data class Person(
    val name: String,
    val surname: String,
    var age: Int) {
    
    fun eat() {}
}

data class User(
    var id: Int? = 0,
    var name: String? = null,
    var content: Content): Codable {
    
    data class Content(val text: String) {}
}
