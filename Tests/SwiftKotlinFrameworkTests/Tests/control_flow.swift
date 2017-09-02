
if number == 3 {}
if (number == 3) {}
if number == nil {}
if item is Movie {}
if !object.condition() {}

// If let constructions
if let number = number {}
if let number = method() {}
if let name = formatter.next(fromIndex: firstTokenIndex) {}
//if case .success(let res) = self {}
if let number = some.method(),
    let param = object.itemAt(number) {}

// If nested closures
if numbers.flatMap({ $0 % 2}).count == 1 {}

// For loops
for current in someObjects {}
for i in 0..<count {}

// Whiles
while condition {}
while (condition) {}

// Guard statements with no statements
guard number == 3 else { return }
guard value() >= 3 else { return }
guard condition else { return }
guard !condition else { return }
guard number == 3 && value() >= 3 else { return }
guard number == 3 || value() >= 3 else { return }

// Guard statements with statements
guard number == 3 else {
    NSLog("Do other operations")
    return
}
guard value() >= 3 else {
    NSLog("Do other operations")
    return
}
guard condition else {
    NSLog("Do other operations")
    return
}
guard !condition else {
    NSLog("Do other operations")
    return
}

// Guard lets
guard let number = number else { return }
guard let value = some.method() else { return }
guard let result = some.method(),
    let param = result.number(),
    param > 1 else { return }
guard let value = some.method() else {
    NSLog("Do other operations")
    return
}
guard let value = some.method() else { throw Exception() }

// Switch
switch nb {
    case 0...7, 8, 9: print("single digit")
    case 10: print("double digits")
    case 11...99: print("double digits")
    default: print("three or more digits")
}
