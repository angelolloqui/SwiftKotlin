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
    
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        let swift = swiftTextView.string ?? ""
        let kotlin = try? swiftKotlin.translate(content: swift)
        kotlinTextView.string = kotlin
    }
}

