
func conditionalFunc2() {
    #if os(iOS) || os(macOS)

        print("not ok: conditionalFunc2\n")

    #elseif KOTLIN
        print("ok: conditionalFunc2\n")
    #else
        print("not ok: conditionalFunc2\n")
    #endif
}


#if KOTLIN
    func conditionalFunc1()
    {
        print("ok: conditionalFunc1\n")
    }
#else
    func conditionalFunc1()
    {
        print("not ok: conditionalFunc1\n")
    }
    // having the #endif on the last line tests an array index bug
#endif
