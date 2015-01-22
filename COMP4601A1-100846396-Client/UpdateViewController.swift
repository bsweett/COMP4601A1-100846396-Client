//
//  UpdateViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var FindButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var addLinkButton: UIButton!
    @IBOutlet weak var deleteLinkButton: UIButton!
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotViewResponseFromServer:", name:"VIEW-XML", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotUpdateResponseFromServer:", name:"UPDATE", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        
        addLinkButton.enabled = false
        deleteLinkButton.enabled = false
        tagsField.enabled = false
        FindButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        idField.enabled = true
        idField.text = ""
        tagsField.text = ""
        titleLabel.text = ""
        linkView.text = ""
        id = ""
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
    
    @IBAction func submitAction(sender: UIBarButtonItem) {
        println("submit pressed")
        SharedNetworkConnection.sharedInstance.updateDocumentOnServer(id, tags: tags, links: linkView.text)
    }
    
    @IBAction func findAction(sender: UIButton) {
        println("find pressed")
        FindButton.enabled = false
        SharedNetworkConnection.sharedInstance.getDocumentOnServerXML(id)
    }
    
    @IBAction func addLinkAction(sender: UIButton) {
        // TODO: open alert similar to create view
    }
    
    @IBAction func deleteLinkAction(sender: UIButton) {
        // TODO: Remove last line of links
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
        
        if(checkCompleteUpdateForm()) {
            self.FindButton.enabled = true
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
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        if(checkCompleteUpdateForm()) {
            self.FindButton.enabled = true
        }
    }

    // MARK: - Button Control
    
    func checkCompleteGetForm() -> Bool {
        
        if(id != "") {
            return true
        }
        
        return false
    }
    
    func checkCompleteUpdateForm() -> Bool {
        
        if(id != "" && tags != "" && linkView.text != "") {
            return true
        }
        
        return false
    }

    // MARK: - NSNotifications
    
    // TODO: get document object from userinfo
    func gotViewResponseFromServer(notification: NSNotification) {
        /*
        let userInfo:Dictionary<String,NSData> = notification.userInfo as Dictionary<String,NSData>
        let response: NSData = userInfo["data"]!*/
        
        // Lock the find unless complete editing or go back to start over
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.idField.enabled = false
            self.FindButton.enabled = false
            
            // TODO: set all the fields before enabling
            
            self.addLinkButton.enabled = true
            if(self.linkView.text != "") {
                self.deleteLinkButton.enabled = true
            }
            self.tagsField.enabled = true
             self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func gotUpdateResponseFromServer(notification: NSNotification) {
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
    
    // TODO: Re-enable proper buttons based on error?
    // Might need to send to different network errors for this one (ie XML has own network error)
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
