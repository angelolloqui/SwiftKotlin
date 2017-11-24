//
//  ViewController.swift
//  SwiftKotlinApp
//
//  Created by Angel Garcia on 09/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Cocoa
import SwiftKotlinFramework
import Transform

class ViewController: NSViewController {

    let swiftTokenizer = SwiftTokenizer()
    let kotlinTokenizer = KotlinTokenizer(
        tokenTransformPlugins: [
            XCTTestToJUnitTokenTransformPlugin()
        ]
    )
    
    @IBOutlet var swiftTextView: NSTextView!
    @IBOutlet var kotlinTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openSwiftFile(_ sender: AnyObject) {
        let oPanel: NSOpenPanel = NSOpenPanel()
        oPanel.canChooseDirectories = false
        oPanel.canChooseFiles = true
        oPanel.allowsMultipleSelection = false
        oPanel.allowedFileTypes = ["swift"]
        oPanel.prompt = "Open"
        
        oPanel.beginSheetModal(for: self.view.window!, completionHandler: { (button: NSApplication.ModalResponse) -> Void in
            if button == NSApplication.ModalResponse.OK {
                let filePath = oPanel.urls.first!.path
                let fileHandle = FileHandle(forReadingAtPath: filePath)
                if let data = fileHandle?.readDataToEndOfFile() {
                    self.swiftTextView.textStorage?.beginEditing()
                    self.swiftTextView.textColor = NSColor.black
                    self.swiftTextView.string = String(data: data, encoding: .utf8) ?? ""
                    self.swiftTextView.textStorage?.endEditing()
                    self.translateSwift()
                }
            }
        })
    }
    
    @IBAction func formatSwift(_ sender: AnyObject) {
        let swift = swiftTextView.string
        let result = swiftTokenizer.translate(content: swift)
        guard let swiftTokens = result.tokens else {
            return
        }
        let formatted = self.attributedStringFromTokens(tokens: swiftTokens)
        self.swiftTextView.textStorage?.beginEditing()
        self.swiftTextView.textStorage?.setAttributedString(formatted)
        self.swiftTextView.textStorage?.endEditing()
    }
    
    func translateSwift() {
        let swift = swiftTextView.string
        let result = kotlinTokenizer.translate(content: swift)
        guard let kotlinTokens = result.tokens else {
            return
        }
        DispatchQueue.main.async {
            self.kotlinTextView.textStorage?.beginEditing()
            let formatted = self.attributedStringFromTokens(tokens: kotlinTokens)
            self.kotlinTextView.textStorage?.setAttributedString(formatted)
            self.kotlinTextView.textStorage?.endEditing()
        }
    }
    
    func attributedStringFromTokens(tokens: [Token]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        tokens.forEach {
            attributedString.append($0.attributedString)
        }
        return attributedString
    }
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        translateSwift()
    }
}


extension Token {
    var attributes: [NSAttributedStringKey : Any] {
        switch self.kind {
        case .keyword:
            return [NSAttributedStringKey.foregroundColor: NSColor(red: 170.0/255.0, green: 13.0/255.0, blue: 145.0/255.0, alpha: 1)]
        case .number, .string:
            return [NSAttributedStringKey.foregroundColor: NSColor(red: 0, green: 116.0/255.0, blue: 0, alpha: 1)]
        case .comment:
            return [NSAttributedStringKey.foregroundColor: NSColor(red: 196.0/255.0, green: 26.0/255.0, blue: 22.0/255.0, alpha: 1)]
        default:
            return [:]
        }
    }
    
    var attributedString: NSAttributedString {
        return NSAttributedString(string: self.value, attributes: self.attributes)
    }
}

