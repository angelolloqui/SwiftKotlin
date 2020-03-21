var boolean: Boolean
var anyObject: Any? = null
var any: Any? = null
var array: List<String>? = null
var array: Promise<List<String>>? = null
var array: List<Promise<List<String>>>
var strings1 = listOf<String>()
var strings2 = listOf("value1", "value2")
var strings3: List<Any> = listOf("value3", "value4")
var map: Map<Int, String>? = null
var map: Promise<Map<Int, String>>? = null
var map: Map<Int, Promise<Map<String, String>>>
var map = mapOf(1 to "a", 2 to "b")
var map = mapOf<String , String>()
method(value = listOf("value1", "value"))
