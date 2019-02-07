

// Ternary and coalescing operators
let value = isTrue ? "yes" : "no"
let label = x > 0 ? "Positive" : "negative"
button.color = item.deleted ? red : green
let text = label ?? "default"

// Wilcard assignments
_ = service.deleteObject()

// Optional chaning
self.service.fetchData()?.user.name?.count
self.data.filter { $0.item?.value == 1 }.map { $0.key }.first?.name.count

// Type casting
self.object =  data as! ObjectType
self.object =  data as? ObjectType
