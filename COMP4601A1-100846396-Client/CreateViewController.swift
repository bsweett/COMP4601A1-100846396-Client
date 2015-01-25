//
//  CreateController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var documentField: UITextView!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var urlField: UITextView!
    @IBOutlet weak var addUrlButton: UIButton!
    
    var tags: String! = ""
    var name: String! = ""
    
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
    
        nameField.delegate = self
        tagField.delegate = self
        documentField.delegate = self
        urlField.delegate = self
        
        SharedHelper.setNavBarForViewController(self, title: "Create Document", withSubmitButton: true)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"CREATE", object: nil)
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
        nameField.text = ""
        tagField.text = ""
        urlField.text = ""
        documentField.text = "Enter your text here"
        name = ""
        tags = ""
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func showLinkAlert(sender: UIButton) {
        
        let alert = UIAlertController(title:  "Enter a URL", message: "URL's are relative to: " + appCurrentServer, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        
        
        let okAction = UIAlertAction(title: "Done", style: .Default) { (action) in
            let pathTextField = alert.textFields![0] as UITextField
            self.urlField.text = self.urlField.text + "\n" + pathTextField.text
            if(self.checkCompleteForm()) {
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
    
    @IBAction func submitAction(sender: UIBarButtonItem) {
        println("Submit Pressed")
        SharedNetworkConnection.sharedInstance.createDocumentOnServer(name, text: documentField.text, tags: tags, links: urlField.text)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text: String = textField.text + string
        
        if(textField == nameField) {
            if(SharedHelper.validName(text)) {
                name = text
            } else {
                name = ""
            }
        } else if(textField == tagField) {
            if(SharedHelper.validTags(text)) {
                tags = text
            } else {
                tags = ""
            }
        }
        
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text: String = textField.text
        if(textField == nameField) {
            if(SharedHelper.validName(text)) {
                name = text
            } else {
                name = ""
                JLToast.makeText("Invalid Name (aplha only 3-35 chars)", duration: JLToastDelay.LongDelay).show()
            }
        } else if(textField == tagField) {
            if(SharedHelper.validTags(text)) {
                tags = text
            } else {
                tags = ""
                JLToast.makeText("Invalid Tags (aplha and ':' only 1 - 255 chars)", duration: JLToastDelay.LongDelay).show()
            }
        }
        
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidEndEditing(textView: UITextView) {
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    // MARK: - Button Control
    
    func checkCompleteForm() -> Bool {
        
        if(name != "" && tags != "" && urlField.text != "" && documentField.text != "") {
            return true
        }
        
        return false
    }
    
    func popView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - NSNotifications
    
    func gotResponseFromServer(notification: NSNotification) {
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
