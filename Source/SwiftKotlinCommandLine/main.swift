//
//  main.swift
//  SwiftKotlinCommandLine
//
//  Created by Angel Garcia on 02/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

let swiftKotlin = SwiftKotlin()
let version = "0.1"
let arguments = [
    "output",
    "help",
    "version",
]

func showHelp() {
    print("swiftkotlin, version \(version)")
    print("copyright (c) 2016 Angel G. Olloqui")
    print("")
    print("usage: swiftkotlin [<file>] [--output path]")
    print("")
    print(" <file>            input file or directory path")
    print(" --output          output path (defaults to input path)")
    print(" --help            this help page")
    print(" --version         version information")
    print("")
}

func expandPath(_ path: String) -> URL {
    let path = NSString(string: path).expandingTildeInPath
    let directoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    return URL(fileURLWithPath: path, relativeTo: directoryURL)
}

func execute(_ args: [String]) {
    guard let args = preprocessArguments(args, arguments) else {
        return
    }
    
    // Show help if requested specifically or if no arguments are passed
    if args["help"] != nil {
        showHelp()
        return
    }
    
    // Version
    if args["version"] != nil {
        print("swiftkotlin, version \(version)")
        return
    }
    
    // Get input / output paths
    let inputURL = args["1"].map { expandPath($0) }
    let outputURL = (args["output"] ?? args["1"]).map { expandPath($0) }
    
    // If no input file, try stdin
    if inputURL == nil {
        var input: String?
        var finished = false
        DispatchQueue.global(qos: .userInitiated).async {
            while let line = readLine(strippingNewline: false) {
                input = (input ?? "") + line
            }
            if let input = input {
                guard let output = try? swiftKotlin.translate(content: input) else {
                    print("error: could not parse input")
                    finished = true
                    return
                }
                if let outputURL = outputURL {
                    if (try? output.write(to: outputURL, atomically: true, encoding: String.Encoding.utf8)) != nil {
                        print("swiftkotlin completed successfully")
                    } else {
                        print("error: failed to write file: \(outputURL.path)")
                    }
                } else {
                    // Write to stdout
                    print(output)
                }
            }
            finished = true
        }
        // Wait for input
        let start = NSDate()
        while start.timeIntervalSinceNow > -0.01 {}
        // If no input received by now, assume none is coming
        if input != nil {
            while !finished && start.timeIntervalSinceNow > -30 {}
        } else {
            showHelp()
        }
        return
    }
    
    print("running swiftkotlin...")
    
    // Format the code
    let start = CFAbsoluteTimeGetCurrent()
    let filesWritten = processInput(inputURL!, andWriteToOutput: outputURL!)
    let time = CFAbsoluteTimeGetCurrent() - start
    print("swiftkotlin completed. \(filesWritten) file\(filesWritten == 1 ? "" : "s") updated in \(String(format: "%.2f", time))s.")
}



func preprocessArguments(_ args: [String], _ names: [String]) -> [String: String]? {
    var anonymousArgs = 0
    var namedArgs: [String: String] = [:]
    var name = ""
    for arg in args {
        if arg.hasPrefix("--") {
            // Long argument names
            let key = arg.substring(from: arg.characters.index(arg.startIndex, offsetBy: 2))
            if !names.contains(key) {
                print("error: unknown argument: \(arg).")
                return nil
            }
            name = key
            continue
        } else if arg.hasPrefix("-") {
            // Short argument names
            let flag = arg.substring(from: arg.characters.index(arg.startIndex, offsetBy: 1))
            let matches = names.filter { $0.hasPrefix(flag) }
            if matches.count > 1 {
                print("error: ambiguous argument: \(arg).")
                return nil
            } else if matches.count == 0 {
                print("error: unknown argument: \(arg).")
                return nil
            } else {
                name = matches[0]
            }
            continue
        }
        if name == "" {
            // Argument is anonymous
            name = String(anonymousArgs)
            anonymousArgs += 1
        }
        namedArgs[name] = arg
        name = ""
    }
    return namedArgs
}


func processInput(_ inputURL: URL, andWriteToOutput outputURL: URL) -> Int {
    let manager = FileManager.default
    var isDirectory: ObjCBool = false
    if manager.fileExists(atPath: inputURL.path, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            if let files = try? manager.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) {
                var filesWritten = 0
                for url in files {
                    let inputDirectory = inputURL.path
                    let path = outputURL.path + url.path.substring(from: inputDirectory.characters.endIndex)
                    let outputDirectory = path.components(separatedBy: "/").dropLast().joined(separator: "/")
                    if (try? manager.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true, attributes: nil)) != nil {
                        filesWritten += processInput(url, andWriteToOutput: URL(fileURLWithPath: path))
                    } else {
                        print("error: failed to create directory at: \(outputDirectory)")
                    }
                }
                return filesWritten
            } else {
                print("error: failed to read contents of directory at: \(inputURL.path)")
            }
        } else if inputURL.pathExtension == "swift" {
            if let input = try? String(contentsOf: inputURL) {
                guard let output = try? swiftKotlin.translate(content: input) else {
                    print("error: could not parse file: \(inputURL.path)")
                    return 0
                }
                if output != input {
                    if (try? output.write(to: outputURL, atomically: true, encoding: String.Encoding.utf8)) != nil {
                        return 1
                    } else {
                        print("error: failed to write file: \(outputURL.path)")
                    }
                }
            } else {
                print("error: failed to read file: \(inputURL.path)")
            }
        }
    } else {
        print("error: file not found: \(inputURL.path)")
    }
    return 0
}


execute(CommandLine.arguments)
