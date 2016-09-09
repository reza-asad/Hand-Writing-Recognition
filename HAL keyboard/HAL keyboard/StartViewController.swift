//
//  StartViewController.swift
//  HAL keyboard
//
//  Created by Alex Fetisova on 9/4/16.
//  Copyright © 2016 Alex Fetisova & Reza Asad. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let color1 = UIColor(red: 1, green: 1, blue: 0.8, alpha: 1).CGColor as CGColorRef
        let color2 = UIColor(red: 0.52, green: 0.71, blue: 0.71, alpha: 1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 0.75]
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
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
