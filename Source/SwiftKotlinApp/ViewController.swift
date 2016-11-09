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
    
    func translateSwift() {
        let swift = swiftTextView.string ?? ""
        let kotlin = try? swiftKotlin.translate(content: swift)
        kotlinTextView.string = kotlin
    }
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        translateSwift()
    }
}

