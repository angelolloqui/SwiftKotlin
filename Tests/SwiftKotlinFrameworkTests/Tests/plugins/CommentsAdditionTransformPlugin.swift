//
//  Header comments
//  Multiple lines together
//
//  Created by Angel Garcia on 14/10/2017.
//

class MyClass {
    
    //Public properties
    var a: Int?
    var b: String?
    
    //Public method
    func aMethod() {
        // A comment inside aMethod
        b = "method run"
        b = b + "more"
    }

    /*
    Multiline comments
    are also supported
    */
    func anotherMethod() {
        if let a = self.a {
            // Inside if
            self.a = a + 1
        } else {
            // Inside else
            self.a = 1
        }
    }
}

// Other comments before structs
struct MyStruct {}

