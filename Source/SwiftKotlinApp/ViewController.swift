//
//  ViewController.swift
//  SwiftKotlinApp
//
//  Created by Angel Garcia on 09/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let swiftKotlin = SwiftKotlin()
    
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
        
        oPanel.beginSheetModal(for: self.view.window!, completionHandler: { (button : Int) -> Void in
            if button == NSFileHandlingPanelOKButton {
                
                let filePath = oPanel.urls.first!.path
                let fileHandle = FileHandle(forReadingAtPath: filePath)
                if let data = fileHandle?.readDataToEndOfFile() {
                    self.swiftTextView.string = String(data: data, encoding: .utf8)
                    self.translateSwift()
                }
            }
        })
    }
    
    func translateSwift(withSwiftFormatting: Bool = true, withKotlinFormatting: Bool = true) {
        
        let swift = swiftTextView.string ?? ""
        let swiftTokens = tokenize(swift)
        let kotlinTokens = (try? self.swiftKotlin.translate(tokens: swiftTokens)) ?? []
        
        DispatchQueue.main.async {
            self.swiftTextView.textStorage?.beginEditing()
            self.kotlinTextView.textStorage?.beginEditing()
            
            if withSwiftFormatting {
                let formatted = self.attributedStringFromTokens(tokens: swiftTokens)
                self.swiftTextView.textStorage?.setAttributedString(formatted)
            }

            if withKotlinFormatting {
                let formatted = self.attributedStringFromTokens(tokens: kotlinTokens)
                self.kotlinTextView.textStorage?.setAttributedString(formatted)                
            }
            else {
                self.kotlinTextView.string = kotlinTokens.reduce("", { $0! + $1.string })
            }
            
            self.swiftTextView.textStorage?.endEditing()
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
    var attributes: [String : Any] {
        switch self {
        case .keyword(_):
            return [NSForegroundColorAttributeName: NSColor(red: 170.0/255.0, green: 13.0/255.0, blue: 145.0/255.0, alpha: 1)]
        case .commentBody(_):
            return [NSForegroundColorAttributeName: NSColor(red: 0, green: 116.0/255.0, blue: 0, alpha: 1)]
        case .stringBody(_), .startOfScope("\""), .endOfScope("\""):
            return [NSForegroundColorAttributeName: NSColor(red: 196.0/255.0, green: 26.0/255.0, blue: 22.0/255.0, alpha: 1)]
        default:
            return [:]
        }
    }
    
    var attributedString: NSAttributedString {
        return NSAttributedString(string: self.string, attributes: self.attributes)
    }
}

