//
//  MainViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // Buttons
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    
    // View Controllers
    var createVC: CreateViewController!
    var SearchVC: SearchViewController!
    var updateVC: UpdateViewController!
    var deleteVC: DeleteViewController!
    
    var viewAllTableVC: DocTableViewController!
    
    // MARK: - Lifecyle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
    adds controller as observer and hides the nav bar
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"VIEWALL", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
    removes the controller as an observer
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    /**
    Creates a createVC if it doesnt exist and pushes it onto the nav stack
    */
    @IBAction func presentCreateView(sender: UIButton) {
        if(self.createVC == nil) {
            self.createVC = CreateViewController(nibName: "CreateViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.createVC, animated: true)
    }
    
    /**
    Creates a searchVC if it doesnt exist and pushes it onto the nav stack
    */
    @IBAction func presentSearchView(sender: UIButton) {
        if(self.SearchVC == nil) {
            self.SearchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.SearchVC, animated: true)
    }
    
    /**
    Creates a updateVC if it doesnt exist and pushes it onto the nav stack
    */
    @IBAction func presentUpdateView(sender: UIButton) {
        if(self.updateVC == nil) {
            self.updateVC = UpdateViewController(nibName: "UpdateViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.updateVC, animated: true)
    }
    
    /**
    Creates a deleteVC if it doesnt exist and pushes it onto the nav stack
    */
    @IBAction func presentDeleteView(sender: UIButton) {
        if(self.deleteVC == nil) {
            self.deleteVC = DeleteViewController(nibName: "DeleteViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.deleteVC, animated: true)
    }
    
    /**
    Disables the view all button and submits a view all documents request
    */
    @IBAction func presentViewAllView(sender: UIButton) {
        
        viewAllButton.enabled = false
        SharedNetworkConnection.sharedInstance.viewAllDocumentsOnServer()
        
    }
    
    // MARK: - NSNotifications
    
    /**
    Gets the documents from the notification and sends them to a docVC before pushing the VC
    onto the stack
    */
    func gotResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<Int,Document> = notification.userInfo as Dictionary<Int,Document>
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.viewAllButton.enabled = true
            if(self.viewAllTableVC == nil) {
                self.viewAllTableVC = DocTableViewController(nibName: "DocTableViewController", bundle: nil)
            }
            
            self.viewAllTableVC.setDocList(userInfo)
            self.navigationController?.pushViewController(self.viewAllTableVC, animated: true)
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
            self.viewAllButton.enabled = true
            self.presentViewController(alert, animated: true) {
                
            }
        }
        
    }
    
}
