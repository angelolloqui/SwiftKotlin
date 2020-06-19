struct Data {
    var text: String
}

public struct Person: Equatable {
    let name: String
    let surname: String
    var age: Int

    internal func eat() {}
    private func incrementAge() {}
}

internal struct User: Codable {
    struct Content {
        let text: String
    }
    var id: Int? = 0
    var name: String?
    var content: Content
}
