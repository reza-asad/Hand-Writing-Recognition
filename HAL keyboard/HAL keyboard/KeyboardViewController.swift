//
//  KeyboardViewController.swift
//  HAL Keyboard
//
//  Created by Alex Fetisova on 8/6/16.
//  Copyright © 2016 Alex Fetisova & Reza Asad. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    var lastPoint: CGPoint?
    let BRUSHWIDTH: CGFloat = 3.0
    let red: CGFloat = 0.0
    let green: CGFloat = 0.0
    let blue: CGFloat = 0.0
    let OPACITY: CGFloat = 1.0
    var swiped = false
    let TESTUSER = "99999"
    typealias Stroke = [[String: Int]]
    var currentStroke = Stroke()
    
    @IBAction func getLetterFromServer(sender: UIButton) {
        if (jsonObject[TESTUSER]!.count > 0) {
            if let jsonStringPretty = JSONStringify(jsonObject) {
                print(jsonStringPretty)
            }
        }
    }
    
    
    @IBAction func nextKeyboardButton(sender: UIButton) {
        advanceToNextInputMode()
    }
    
    @IBAction func clearDrawing(sender: UIButton) {
        print("xxxxxxxxxxxxxxxxx CLEAR xxxxxxx")
        jsonObject[TESTUSER] = []
        letterDrawView.image = nil
        letterDrawView.backgroundColor = UIColor.whiteColor()
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
    
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        jsonObject[TESTUSER] = []
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
                print("--------began touch--------")
                lastPoint = touchedPoint
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        let x = Int(round(fromPoint.x))
        let y = Int(round(fromPoint.y))
        let timeInMS = Int(round((NSDate().timeIntervalSince1970) * 1000))
        print("x: \(x), y: \(y), time: \(timeInMS)")
        let coords: [String: Int] = ["x": x, "y": y, "time": timeInMS]
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
        CGContextSetRGBStrokeColor(context, red, green, blue, OPACITY)
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
        print("-----------end touch-----------")
        if (currentStroke.count > 0) {
            jsonObject[TESTUSER]!.append(currentStroke)
            currentStroke = []
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    // https://medium.com/swift-programming/4-json-in-swift-144bf5f88ce4#.nt7yor8tz
    func JSONStringify(value: AnyObject, prettyPrinted:Bool = false) -> String? {
        
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        
        if NSJSONSerialization.isValidJSONObject(value) {
            
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            } catch {
                print("JSON conversion error")
                return nil
            }
            
        }
        return nil
    }
    

}
