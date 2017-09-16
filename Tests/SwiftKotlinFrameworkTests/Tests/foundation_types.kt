lateinit var boolean: Boolean
var anyObject: Any? = null
var any: Any? = null
lateinit var array: List<String>?
lateinit var array: Promise<List<String>>?
lateinit var array: List<Promise<List<String>>>
var array = listOf("1", "2")
lateinit var map: Map<Int, String>?
lateinit var map: Promise<Map<Int, String>>?
lateinit var map: Map<Int, Promise<Map<String, String>>>
var map = mapOf(1 to "a", 2 to "b")
