internal var completionHandlers: List<() -> Unit> = listOf()

internal fun someFunctionWithEscapingClosure(completionHandler: () -> Unit) {
    completionHandlers.append(completionHandler)
}

internal fun serve(customerProvider: () -> String) {
    print("Now serving ${customerProvider()}!")
}

internal fun collectCustomerProviders(customerProvider: () -> String) {
    customerProviders.append(customerProvider)
}

internal fun foo(code: (() -> String)) : String =
    "foo ${bar(code)}"
