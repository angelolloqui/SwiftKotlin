struct Data {
    var text: String
}

struct Person: Equatable {
    let name: String
    let surname: String
    var age: Int

    func eat() {}
}

struct User: Codable {
    struct Content {
        let text: String
    }
    var id: Int? = 0
    var name: String?
    var content: Content
}
