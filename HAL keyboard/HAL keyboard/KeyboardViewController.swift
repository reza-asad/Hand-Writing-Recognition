//
//  KeyboardViewController.swift
//  HAL Keyboard
//
//  Created by Alex Fetisova on 8/6/16.
//  Copyright © 2016 Alex Fetisova & Reza Asad. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

  //  @IBOutlet var nextKeyboardButton: UIButton!
    var keyboardView: UIView!
    
    /*
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        /*
        self.nextKeyboardButton = UIButton(type: .System)
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
    
        self.nextKeyboardButton.addTarget(self, action: #selector(advanceToNextInputMode), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        self.nextKeyboardButton.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.nextKeyboardButton.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        */
    }
    
    func loadInterface() {
        // load the nib file
        let keyboardNib = UINib(nibName: "KeyboardView", bundle: nil)
        // instantiate the view
        keyboardView = keyboardNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        keyboardView.frame = self.view.frame
    
        // add the interface to the main view
        view.addSubview(keyboardView)
        
        // copy the background color
        view.backgroundColor = keyboardView.backgroundColor
    }

    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }*/

}
