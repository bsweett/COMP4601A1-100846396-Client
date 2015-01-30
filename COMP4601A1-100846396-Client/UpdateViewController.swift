//
//  UpdateViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var idField: UITextField!
    
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var addLinkButton: UIButton!
    @IBOutlet weak var linkView: UITextView!
    
    var id: String! = ""
    var tags: String! = ""
    
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
        SharedHelper.setNavBarForViewController(self, title: "Update Document", withSubmitButton: true)
    }
    
    /**
    adds this controller as an observer and disables the submit button
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        idField.delegate = self
        tagsField.delegate = self
        linkView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotViewResponseFromServer:", name:"VIEW-XML", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotUpdateResponseFromServer:", name:"UPDATE", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
    Removes this controller as an observer and clears the fields
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        idField.text = ""
        tagsField.text = ""
        linkView.text = ""
        id = ""
        tags = ""
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    /**
    Submits an update request to the server
    */
    @IBAction func submitAction(sender: UIBarButtonItem) {
        SharedNetworkConnection.sharedInstance.updateDocumentOnServer(id, tags: tags, links: linkView.text)
    }
    
    /**
    Shows a link alert and handles all entry of links into the urlfield
    */
    @IBAction func addLinkAction(sender: UIButton) {
        
        let alert = UIAlertController(title:  "Enter a URL", message: "URL's are relative to: " + appCurrentServer, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        
        
        let okAction = UIAlertAction(title: "Done", style: .Default) { (action) in
            let pathTextField = alert.textFields![0] as UITextField
            self.linkView.text = self.linkView.text + "\n" + pathTextField.text
            if(self.checkCompleteUpdateForm()) {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
        }
        okAction.enabled = false
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "URL"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                
                if(SharedHelper.validatePathEntry(textField.text) && (textField.text as NSString).length >= 2) {
                    okAction.enabled = true
                }
            }
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true) {
            // ...
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text: String = textField.text + string
        
        if(textField == idField) {
            if(SharedHelper.validId(text)) {
                id = text
            } else {
                id = ""
            }
        } else if(textField == tagsField) {
            if(SharedHelper.validTags(text)) {
                tags = text
            } else {
                tags = ""
            }
        }
        
        if(checkCompleteUpdateForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text: String = textField.text
        if(textField == idField) {
            if(SharedHelper.validId(text)) {
                id = text
            } else {
                id = ""
                JLToast.makeText("Invalid ID", duration: JLToastDelay.LongDelay).show()
            }
        } else if(textField == tagsField) {
            if(SharedHelper.validTags(text)) {
                tags = text
            } else {
                tags = ""
                JLToast.makeText("Invalid Tags (aplha and ':' only 1 - 255 chars)", duration: JLToastDelay.LongDelay).show()
            }
        }
        
        if(checkCompleteUpdateForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    // MARK: - Button Control
    
    /**
    Checks that the form is complete
    */
    func checkCompleteUpdateForm() -> Bool {
        
        if(id != "" && tags != "" && linkView.text != "") {
            return true
        }
        
        return false
    }
    
    /**
    pops this view from the nav stack
    */
    func popView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - NSNotifications
    
    /**
    Gets the response from the notification and sends it to a alert controller before displaying it
    */
    func gotUpdateResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as Dictionary<String,String>
        let response: String = userInfo["message"]!
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let alert = UIAlertController(title:  "SDA Response", message: response, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                
            }
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                self.popView()
            })
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
