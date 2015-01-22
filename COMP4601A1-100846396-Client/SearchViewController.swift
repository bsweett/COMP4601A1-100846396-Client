//
//  SearchViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchField: UITextField!
    
    var searchText: String! = ""
    
    var webVC: WebViewController!
    
    // MARK: - Lifecyle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
        
        SharedHelper.setNavBarForViewController(self, title: "Search Documents", withSubmitButton: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"VIEW", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"SEARCH", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        searchField.text = ""
        searchText = ""
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func submitAction(sender: UIBarButtonItem) {
        println("Submit Pressed")
        if searchText.rangeOfString(":") != nil {
            SharedNetworkConnection.sharedInstance.searchDocumentsOnServer(searchText)
        } else {
            SharedNetworkConnection.sharedInstance.getDocumentOnServer(searchText)
        }
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text: String = textField.text + string
        
        if(textField == searchField) {
            if(SharedHelper.validId(text) || SharedHelper.validTags(text)) {
                searchText = text
            } else {
                searchText = ""
            }
        }
        
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text: String = textField.text
        if(textField == searchField) {
            if(SharedHelper.validId(text) || SharedHelper.validTags(text)) {
                searchText = text
            } else {
                searchText = ""
                JLToast.makeText("Invalid ID or Tag", duration: JLToastDelay.LongDelay).show()
            }
        }
        
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }

    
    // MARK: - Form State
    
    func checkCompleteForm() -> Bool{
        if(searchText != "") {
            return true
        }
        
        return false
    }
    
    // MARK: - NSNotifications
    
    func gotResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<String,NSData> = notification.userInfo as Dictionary<String,NSData>
        let response: NSData = userInfo["data"]!
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if(self.webVC == nil) {
                self.webVC = WebViewController(nibName: "WebViewController", bundle: nil)
            }
            
            self.webVC.setViewData(response)
            self.navigationController?.pushViewController(self.webVC, animated: true)
        }
    }
    
    func gotNetworkError(notification: NSNotification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as Dictionary<String,String>
        let error: String = userInfo["error"]!
        
        let alert = UIAlertController(title:  "Network Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
            
        }
        alert.addAction(cancelAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true) {
                
            }
        }
    }
        
}