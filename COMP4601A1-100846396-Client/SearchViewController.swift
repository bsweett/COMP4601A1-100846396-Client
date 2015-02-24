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
    var viewMultiVC: DocTableViewController!
    
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
        
        SharedHelper.setNavBarForViewController(self, title: "Query Local Documents", withSubmitButton: true)
    }
    
    /**
        Adds the controller as an observer and disables the submit button
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"VIEW", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotXMLResponseFromServer:", name:"QUERY", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"QUERY-HTML", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
        Removes the controller as an observer and clears the fields
    */
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
    
    /**
        Submits either a search by tag or id based on the form input
    */
    @IBAction func submitAction(sender: UIBarButtonItem) {
        
        if (searchText.rangeOfString("+") != nil){
            SharedNetworkConnection.sharedInstance.queryLocalDocumentsOnServer(searchText)
        } else {
            SharedNetworkConnection.sharedInstance.getDocumentOnServer(searchText)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text: String = textField.text + string
        
        if(textField == searchField) {
            if(SharedHelper.validId(text) || SharedHelper.validTerms(text)) {
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
            if(SharedHelper.validId(text) || SharedHelper.validTerms(text)) {
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
    
    /**
        Checks if the form is complete
    */
    func checkCompleteForm() -> Bool{
        if(searchText != "") {
            return true
        }
        
        return false
    }
    
    // MARK: - NSNotifications
    
    /**
        Gets the HTML data from the notification and sends it to a web controller before pushing it onto the
        nav stack
    */
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
    
    /**
        Gets the documents from the notification and sends them to a docVC before pushing the VC
        onto the stack
    */
    func gotXMLResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<Int,Document> = notification.userInfo as Dictionary<Int,Document>
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if(self.viewMultiVC == nil) {
                self.viewMultiVC = DocTableViewController(nibName: "DocTableViewController", bundle: nil)
            }
            
            self.viewMultiVC.setDocList(userInfo)
            self.navigationController?.pushViewController(self.viewMultiVC, animated: true)
        }
    }
    
    /**
        Gets the error from the notification and sends it to an alert controller before displaying it
    */
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