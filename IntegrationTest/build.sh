DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD=$DIR/build
mkdir -p $BUILD
mkdir -p $BUILD/kt
mkdir -p $BUILD/jar

set -e

echo "Compiling tool..."
xcodebuild  -workspace ../SwiftKotlin.xcworkspace -scheme SwiftKotlinCommandLine SYMROOT=$BUILD > $BUILD/xcodebuild.log

echo "Compiling swift..."
swiftc src/constructors.swift src/conditional.swift -o $BUILD/swiftout -emit-module -module-name test

echo "Transpiling swift..."
$BUILD/Debug/swiftkotlin --define KOTLIN src --output $BUILD/kt

echo "Compiling kotlin..."
kotlinc src/hello.kt $BUILD/kt -include-runtime -d $BUILD/jar/test.jar

echo "Running jar..."
java -Xverify:all -jar $BUILD/jar/test.jar