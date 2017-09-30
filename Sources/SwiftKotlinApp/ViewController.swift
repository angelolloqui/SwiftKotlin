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
    let kotlinTokenizer = KotlinTokenizer()
    
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
                    self.swiftTextView.string = String(data: data, encoding: .utf8) ?? ""
                    self.translateSwift()
                }
            }
        })
    }
    
    func translateSwift(withSwiftFormatting: Bool = true, withKotlinFormatting: Bool = true) {
        do {
            let swift = swiftTextView.string
            let swiftTokens = try swiftTokenizer.translate(content: swift)
            let kotlinTokens = try kotlinTokenizer.translate(content: swift)

            DispatchQueue.main.async {
                self.swiftTextView.textStorage?.beginEditing()
                self.kotlinTextView.textStorage?.beginEditing()

                if withSwiftFormatting {
                    let formatted = self.attributedStringFromTokens(tokens: swiftTokens)
                    self.swiftTextView.textStorage?.setAttributedString(formatted)
                }
                else {
                    self.swiftTextView.string = swiftTokens.joinedValues()
                }

                if withKotlinFormatting {
                    let formatted = self.attributedStringFromTokens(tokens: kotlinTokens)
                    self.kotlinTextView.textStorage?.setAttributedString(formatted)
                }
                else {
                    self.kotlinTextView.string = kotlinTokens.joinedValues()
                }

                self.swiftTextView.textStorage?.endEditing()
                self.kotlinTextView.textStorage?.endEditing()
            }
        } catch {}
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

