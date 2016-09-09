//
//  PunctuationViewController.swift
//  HAL keyboard
//
//  Created by Alex Fetisova on 9/5/16.
//  Copyright © 2016 Alex Fetisova & Reza Asad. All rights reserved.
//

import UIKit

class PunctuationViewController: UIViewController {

    @IBOutlet weak var buttonStack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in buttonStack.subviews {
            for button in (subview as! UIStackView).subviews {
                (button as! UIButton).layer.cornerRadius = 10
                (button as! UIButton).layer.borderWidth = 1
                (button as! UIButton).layer.borderColor = UIColor.blackColor().CGColor
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
