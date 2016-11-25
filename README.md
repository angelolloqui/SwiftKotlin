![](Assets/logo_small.png)

[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@angelolloqui-blue.svg?maxAge=2592000)](http://twitter.com/angelolloqui)

# SwiftKotlin

A tool to convert Swift code to Kotlin in a very easy and quick way.

![](Assets/screenshot.png)

# What is this?

SwiftKotlin is a framework, a command line tool and a Mac application for **translating Swift code into Kotlin**.

It applies transformations to the Swift code to get as correct as possible Kotlin code (see limitations below). It does string transformations as well as some more complicated ones like transforming `guard` statements to negative `if` statements, properties, memory management and many others.

It comes with a desktop Mac application to copy & paste your code, as well as a command line tool to transform a complete project to Kotlin.


## Why use SwiftKotlin?

### Why Kotlin?
Kotlin is a great language, it is to Android/Java what Swift is to iOS/Objective-C. It adds lots of great features while at the same time it keeps complete interop to Java, which means that you can combine them both together at your best preference. 

**If you are a Swift developer**, you will love Kotlin. It provides the most important Swift features (optionals, extensions, generics, lambdas,...) and a very similar syntax. You can check a [side by side comparison of Swift and Kotlin here](https://nilhcem.github.io/swift-is-like-kotlin/).

**If you are a Java developer**, you will find in Kotlin a much more modern and safer language (optionals!). It is a pleasure to write Kotlin code, much more readable and compact that the Java counterpart. You can check some of the [benefits and differences in Kotlin official documentation](https://kotlinlang.org/docs/reference/comparison-to-java.html)

Moreover, Kotlin is fully integrated in IntelliJ (Android Studio), so you can keep using the "de facto" IDE for Android with all the added benefits brought by Google, and it even have a Java to Kotlin converter if you want to update your legacy Java.

On top of that, if you consider the similarities between Swift and Kotlin, you can very easily convert code in one language to the other one, and have Swift developers writing Kotlin (and viciversa) with ease. That is in fact the porpose of this project, to help you doing that conversion.


### Benefits over shared code accross platforms
There are many alternatives for making multiplatform projects or sharing code between them. Some alternatives are [Xamarin](https://www.xamarin.com/), [ReactNative](https://facebook.github.io/react-native/), [Cordova](https://cordova.apache.org/) or low level C++ libraries.

The main issue with all of them is that once you chose to use them, you need to keep in there boundaries, including specific tools and libraries, introducing a steep learning curve and a big risk in terms of dependency to that 3rd party. Besides that, in many of those options the resulting app will lack the quality of a fully native app.

On the other hand, by using Kotlin, you will still have 2 fully native applications, with all the benefits (best quality, performance, best tools per platform -Xcode/Android Studio-, follow platform conventions,...) but at the same time keep very low the extra work required to translate between them due to its similarity to Swift. 

In fact, [I explored an actual example using MVVM+Rx](http://angelolloqui.com/blog/38-Swift-vs-Kotlin-for-real-iOS-Android-apps), where I got between a 50% and 90% of code similarity depending on the layer (non UIKit dependent is much more reusable than UIKit dependent classes of course). It took me around 30% the time to convert the Android version from the iOS version and I did not had SwiftKotlin by then ;)


## Limitations
Despite the similarities, Swift and Kotlin are different languages, with some intrinsic differences in them that can not be fully translated. Besides that, they both run in different environments and have access very different frameworks and system libraries.

Because of that, this **tool does not have as a goal to produce production ready Kotlin code**, but just a Kotlin translation that **will require manual edition**. For example, things as simple as adding a new item to an array has different method names:

```
//Swift 3
array.append("This is in Swift")
```
```
//Kotlin
array.add("This is in Kotlin")
```

The scope of this project is not mapping all existing methods and data types to its Kotlin counterpart, but to translate the language itself. This means that manual editing will be required afterwards, especially when dealing with system libraries, but it is intentional and important that the developer checks the output.


## Status
The project is in active development, with many rules still to be implemented. Some of them include:

- [ ] Constructors
- [x] Simple Control flow statments (`guard`, `if`, `for`, `while`, `switch`)
- [ ] Composed Control flow statments (multiple `guard`, `if` let)
- [ ] Exception handling
- [ ] Extensions
- [x] Keyword replacements (`val`, `this`, `fun`, ...)
- [ ] Memory management
- [x] Parameter names
- [ ] Function returns and named parameters
- [x] Property transfromers
- [x] Static to Companion
- [x] Struct to data class
- ...

However, with the implemented rules you can get already a pretty decent Kotlin output for many of your classes. The rest will come in future releases.


## Installation
The project comes with 2 executable targets:

- **SwiftKotlinCommandLine**
- **SwiftKotlinApp**

You can download the project and execute them in XCode8+ or just go to the download page to get the most recent compiled versions of the project.

Copy the executables in a directory with executable rights. Typically, you could use:

- **swiftkotlin** command line tool: `/usr/local/bin/`
- **SwiftKotlin** desktop app: `/Applications/`

## Usage
### Command line tool
If you placed `swiftkotlin` in your any of your path directories, just run: `swiftkotlin [<file>] [--output path]`

Note that you can specify a directory as input. Output will be default use the input directory, creating a `<name>.kt` file for each existing `<name>.swift` file found. 


## License

MIT licensed.

## Collaboration

Forks, patches and other feedback are always welcome.

//TODO: Contribution guideline


## Credits

SwiftKotlin uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat/) for extracting tokens from the Swift file.

SwiftKotlin is brought to you by [Angel Garcia Olloqui](http://angelolloqui.com). You can contact me on:

Project Page: [SwiftKotlin](https://github.com/angelolloqui/SwiftKotlin)

Personal webpage: [angelolloqui.com](http://angelolloqui.com)

Twitter: [@angelolloqui](http://twitter.com/angelolloqui)

LinkedIn: [angelolloqui](http://www.linkedin.com/in/angelolloqui)


