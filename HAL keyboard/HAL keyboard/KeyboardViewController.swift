//
//  KeyboardViewController.swift
//  HAL Keyboard
//
//  Created by Alex Fetisova on 8/6/16.
//  Copyright © 2016 Alex Fetisova & Reza Asad. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, UIPopoverPresentationControllerDelegate, SelectedColorDelegate {
    var lastPoint: CGPoint?
    let BRUSHWIDTH: CGFloat = 3.0
    let OPACITY: CGFloat = 1.0
    var swiped = false
    let TESTUSER = "99999"
    typealias Stroke = [[String: AnyObject]]
    var currentStroke = Stroke()
    let URL = NSURL(string: "http://new-flask-env.fjx3ah5cp2.us-west-2.elasticbeanstalk.com/letter")
    var currentColor = UIColor.blackColor()
    
    @IBAction func getLetterFromServer(sender: UIButton) {
        if (jsonObject[TESTUSER]!.count > 0) {
            UIPasteboard.generalPasteboard().image = letterDrawView.image
            if let jsonData = JSONStringify(jsonObject) {
                let response = sendHTTPRequest(jsonData)
                print(response)
            } 
        }
        clearScreen();
    }
    
    func clearScreen() {
        jsonObject[TESTUSER] = []
        letterDrawView.image = nil
        letterDrawView.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func backspace(sender: UIButton) {
        textDocumentProxy.deleteBackward()
    }
    
    
    @IBAction func nextKeyboardButton(sender: UIButton) {
        advanceToNextInputMode()
    }
    
    @IBAction func clearDrawing(sender: UIButton) {
        clearScreen()
    }
    
    @IBAction func showColorPalette(sender: UIButton) {
        print("show color palette")
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Palette Collection") as! PaletteCollectionViewController
        vc.delegate = self
        vc.modalPresentationStyle = .Popover
        vc.preferredContentSize = CGSize(width: 100, height: 200)
        
        //let vw = vc.view
        let popoverMenuViewController = vc.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Left
        popoverMenuViewController?.delegate = self
        popoverMenuViewController?.sourceView = sender
        popoverMenuViewController?.sourceRect = sender.bounds
        self.presentViewController(vc, animated: true, completion: nil)
1
    }
    
    @IBAction func showPunctuation(sender: UIButton) {
        print("show punctuation")
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Punctuation") as! PunctuationViewController
        vc.modalPresentationStyle = .Popover
        vc.preferredContentSize = CGSize(width: 300, height: 200)
        
        //let vw = vc.view
        let popoverMenuViewController = vc.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Right
        popoverMenuViewController?.delegate = self
        popoverMenuViewController?.sourceView = sender
        popoverMenuViewController?.sourceRect = sender.bounds
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    @IBOutlet weak var option1: UIButton!
    @IBOutlet weak var option2: UIButton!
    @IBOutlet weak var option3: UIButton!
    
    @IBAction func selectLetter(sender: UIButton) {
        if let letter = sender.titleLabel?.text {
            textDocumentProxy.insertText(letter)
        }
    }
    
    /* holds the json data for letter's strokes in the format
     * {'user_id': [
     *      [{'time': time, 'x': x, 'y': y}, {'time': time, 'x': x, 'y': y}, ...], -- a stroke
     *      [{'time': time, 'x': x, 'y': y}], -- another stroke
     *      ...
     * ]}
     *
     */
    var jsonObject = [String: [Stroke]]()
    
    var keyboardView: UIView!
    
    @IBOutlet weak var letterDrawView: UIImageView!
    
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var Xbutton: UIButton!
    @IBOutlet weak var backspaceButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var punctuationButton: UIButton!
    
    func setButtonDesign() {
        keyboardButton.layer.cornerRadius = 10
        keyboardButton.layer.borderColor = UIColor.blackColor().CGColor
        keyboardButton.layer.borderWidth = 1.0
        colorButton.layer.cornerRadius = 10
        colorButton.layer.borderColor = UIColor.blackColor().CGColor
        colorButton.layer.borderWidth = 1.0
        
        Xbutton.layer.cornerRadius = 10
        Xbutton.layer.borderColor = UIColor.blackColor().CGColor
        Xbutton.layer.borderWidth = 1.0
        backspaceButton.layer.cornerRadius = 10
        backspaceButton.layer.borderColor = UIColor.blackColor().CGColor
        backspaceButton.layer.borderWidth = 1.0
        acceptButton.layer.cornerRadius = 10
        acceptButton.layer.borderColor = UIColor.blackColor().CGColor
        acceptButton.layer.borderWidth = 1.0
        punctuationButton.layer.cornerRadius = 10
        punctuationButton.layer.borderColor = UIColor.blackColor().CGColor
        punctuationButton.layer.borderWidth = 1.0
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        jsonObject[TESTUSER] = []
        setButtonDesign()
    }
    
    func loadInterface() {
        keyboardView = NSBundle.mainBundle().loadNibNamed("KeyboardView", owner: self, options: nil)[0] as! UIView
        keyboardView.frame = self.view.frame
        // add the interface to the main view
        view.addSubview(keyboardView)
        // copy the background color
        view.backgroundColor = keyboardView.backgroundColor
        letterDrawView.layer.cornerRadius = 10
        letterDrawView.clipsToBounds = true
    }

    func sendHTTPRequest(jsonBody: NSData) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "POST"
        // insert json data to the request
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody
        
        // async request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil {
                print("Error -> \(error)")
                return
            }
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:String]
                if let result = result {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.option1.setTitle(result["1"], forState: .Normal)
                        self.option2.setTitle(result["2"], forState: .Normal)
                        self.option3.setTitle(result["3"], forState: .Normal)
                    })
                }
                print("Result -> \(result)")
                
            } catch {
                print("Error -> \(error)")
            }
        }
        
        task.resume()
        return task
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    /*
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
    }
 */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first { // touching possible with only 1 finger
            let touchedPoint = touch.locationInView(letterDrawView)
            if (CGRectContainsPoint(letterDrawView.bounds, touchedPoint)) {
                //print("--------began touch--------")
                lastPoint = touchedPoint
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        let x = Int(round(fromPoint.x))
        let y = Int(round(fromPoint.y))
        let timeInMS = CUnsignedLongLong(round((NSDate().timeIntervalSince1970) * 1000))
        //print("x: \(x), y: \(y), time: \(timeInMS)")
        let coords: [String: AnyObject] = ["x": x, "y": y, "time": NSNumber(unsignedLongLong: timeInMS)]
        currentStroke.append(coords)
        UIGraphicsBeginImageContext(letterDrawView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        letterDrawView.image?.drawInRect(CGRect(x: 0, y: 0, width: letterDrawView.frame.size.width, height: letterDrawView.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, BRUSHWIDTH)
        CGContextSetStrokeColorWithColor(context, currentColor.CGColor)
        //CGContextSetRGBStrokeColor(context, currentColor.CGColor, currentColor.CIColor.green, currentColor.CIColor.blue, OPACITY)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        letterDrawView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(letterDrawView)
            if let lastPoint = lastPoint where CGRectContainsPoint(letterDrawView.bounds, currentPoint){
                drawLineFrom(lastPoint, toPoint: currentPoint)
                self.lastPoint = currentPoint
            } else {
                self.lastPoint = nil
            }
            
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let lastPoint = lastPoint where !swiped {
            // draw a point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        //print("-----------end touch-----------")
        if (currentStroke.count > 0) {
            jsonObject[TESTUSER]!.append(currentStroke)
            currentStroke = []
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    // https://medium.com/swift-programming/4-json-in-swift-144bf5f88ce4#.nt7yor8tz
    func JSONStringify(value: AnyObject, prettyPrinted:Bool = false) -> NSData? {
        
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        
        if NSJSONSerialization.isValidJSONObject(value) {
            
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                /*if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }*/
                return data
            } catch {
                print("JSON conversion error")
                return nil
            }
            
        }
        return nil
    }
    
    func selectedColor(color: UIColor) {
        currentColor = color
    }
    

}
