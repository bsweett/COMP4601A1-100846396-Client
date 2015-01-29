//
//  SharedControllerFunctions.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class SharedHelper {
    
    //Creating Singleton instance of the class
    class var sharedInstance: SharedHelper {
        struct Static {
            static var instance: SharedHelper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SharedHelper()
        }
        
        return Static.instance!
    }
   
    class func setNavBarForViewController(vc: UIViewController, title: String, withSubmitButton: Bool) {
        var nav = vc.navigationController?.navigationBar
        nav?.tintColor = UIColor.whiteColor()
        vc.title = title
        nav?.barTintColor = UIColor.blackColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        if(withSubmitButton == true) {
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Plain, target:vc, action: Selector("submitAction:"))
        }
    }
    
    class func validatePathEntry(testStr: String) -> Bool{
        let regex = NSRegularExpression(pattern: "^(/)?([^/\0]+(/)?)+$", options: .CaseInsensitive, error: nil)
            
        return regex?.firstMatchInString(testStr, options: nil, range: NSMakeRange(0, countElements(testStr))) != nil
    }
    
    class func validName(testStr: String) -> Bool {
        let regex = NSRegularExpression(pattern: "^([a-zA-Z]){3,35}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(testStr, options: nil, range: NSMakeRange(0, countElements(testStr))) != nil
    }
    
    class func validTags(testStr: String) -> Bool {
        let regex = NSRegularExpression(pattern: "^([a-zA-Z:]){1,255}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(testStr, options: nil, range: NSMakeRange(0, countElements(testStr))) != nil
    }
    
    class func buildTagsArrayFromString(text: String) -> [String] {
        var arr = split(text) {$0 == ":"}
        return arr
    }
    
    class func buildLinksArrayFromString(text: String) -> [String] {
        var arr = text.componentsSeparatedByString("\n")
        return arr
    }
    
    class func validId(testStr: String) -> Bool {
        let regex = NSRegularExpression(pattern: "^[0-9]*$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(testStr, options: nil, range: NSMakeRange(0, countElements(testStr))) != nil
    }
    
}
