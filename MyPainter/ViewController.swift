//
//  ViewController.swift
//  MyPainter
//
//  Created by Joseph Chen on 2020/1/14.
//  Copyright © 2020 Joseph Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var painterView: PainterView!
    @IBOutlet var picker: UISegmentedControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        painterView.captureBackgroundContents()
    }
    
    @IBAction func onPickerValueChanged(_ sender: UISegmentedControl) {
       
        if sender.selectedSegmentIndex == 0 {
            self.painterView.eraseMode = false
        }
        else {
            self.painterView.eraseMode = true
        }
    }     
}

