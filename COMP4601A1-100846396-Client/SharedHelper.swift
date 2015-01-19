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
    
}
