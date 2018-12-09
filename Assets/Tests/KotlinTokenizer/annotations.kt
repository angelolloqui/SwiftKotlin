var completionHandlers: List<() -> Unit> = listOf()

fun someFunctionWithEscapingClosure(completionHandler: () -> Unit) {
    completionHandlers.append(completionHandler)
}

fun serve(customerProvider: () -> String) {
    print("Now serving ${customerProvider()}!")
}

fun collectCustomerProviders(customerProvider: () -> String) {
    customerProviders.append(customerProvider)
}

fun foo(code: (() -> String)) : String =
    "foo ${bar(code)}"
