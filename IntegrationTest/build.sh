DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD=$DIR/build
mkdir -p $BUILD
mkdir -p $BUILD/kt
mkdir -p $BUILD/jar

set -e

echo "Compiling tool..."
xcodebuild  -workspace ../SwiftKotlin.xcworkspace -scheme SwiftKotlinCommandLine SYMROOT=$BUILD > $BUILD/xcodebuild.log

echo "Compiling swift..."
swiftc constructors.swift -o $BUILD/swiftout

echo "Transpiling swift..."
$BUILD/Debug/swiftkotlin constructors.swift --output $BUILD/kt/constructors.kt

echo "Compiling kotlin..."
kotlinc hello.kt $BUILD/kt/constructors.kt -include-runtime -d $BUILD/jar/test.jar

echo "Running jar..."
java -Xverify:all -jar $BUILD/jar/test.jar