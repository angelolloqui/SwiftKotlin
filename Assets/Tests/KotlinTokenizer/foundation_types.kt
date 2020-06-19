internal var boolean: Boolean
internal var anyObject: Any? = null
internal var any: Any? = null
internal var array: List<String>? = null
internal var array: Promise<List<String>>? = null
internal var array: List<Promise<List<String>>>
internal var strings1 = listOf<String>()
internal var strings2 = listOf("value1", "value2")
internal var strings3: List<Any> = listOf("value3", "value4")
internal var map: Map<Int, String>? = null
internal var map: Promise<Map<Int, String>>? = null
internal var map: Map<Int, Promise<Map<String, String>>>
internal var map = mapOf(1 to "a", 2 to "b")
internal var map = mapOf<String , String>()
method(value = listOf("value1", "value"))
