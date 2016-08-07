//
//  ViewController.swift
//  HAL keyboard
//
//  Created by Alex Fetisova on 8/6/16.
//  Copyright © 2016 Alex Fetisova & Reza Asad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

