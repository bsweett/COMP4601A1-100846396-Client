//
//  MainViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // A1 Buttons
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    
    // A2 Buttons
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var noboostButton: UIButton!
    @IBOutlet weak var sdaSerachButton: UIButton!
    @IBOutlet weak var pageRankButton: UIButton!
    
    // A1 View Controllers
    var createVC: CreateViewController!
    var SearchVC: SearchViewController!
    var updateVC: UpdateViewController!
    var deleteVC: DeleteViewController!
    
    var viewAllTableVC: DocTableViewController!
    
    // A2 View Controllers
    var webVC: WebViewController!
    var sdaSearchVC: SdaSearchViewController!
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotViewAllResponseFromServer:", name:"VIEWALL", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotHTTPResponseFromServer:", name:"RESET", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotHTTPResponseFromServer:", name:"BOOST", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotHTTPResponseFromServer:", name:"NOBOOST", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotHTMLResponseFromServer:", name:"LIST", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotHTMLResponseFromServer:", name:"PAGERANK", object: nil)
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
    
    // MARK: - A1 Actions
    
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
    
    // MARK: - A2 Actions
    
    @IBAction func resetSdaOnServer(sender: UIButton) {
        
        resetButton.enabled = false
        SharedNetworkConnection.sharedInstance.sdaResetRequest()
    }
    
    @IBAction func listSdasOnServer(sender: UIButton) {
        
        listButton.enabled = false
        SharedNetworkConnection.sharedInstance.sdaListRequest()
    }
    
    @IBAction func boostSdaDocumentsOnServer(sender: UIButton) {
        
        boostButton.enabled = false
        SharedNetworkConnection.sharedInstance.sdaBoostRequest()
    }
    
    @IBAction func removeBoostFromSdaDocumentsOnServer(sender: UIButton) {
        
        noboostButton.enabled = false
        SharedNetworkConnection.sharedInstance.sdaNoBoostRequest()
    }
    
    @IBAction func presentSdaSearchView(sender: UIButton) {
        if(self.sdaSearchVC == nil) {
            self.sdaSearchVC = SdaSearchViewController(nibName: "SdaSearchViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.sdaSearchVC, animated: true)
    }
    
    @IBAction func displayPageRankFromServer(sender: UIButton) {
        
        pageRankButton.enabled = false
        SharedNetworkConnection.sharedInstance.sdaPageRankRequest()
    }
    
    // MARK: - NSNotifications
    
    /**
    Gets the documents from the notification and sends them to a docVC before pushing the VC
    onto the stack
    */
    func gotViewAllResponseFromServer(notification: NSNotification) {
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
    
    
    func gotHTTPResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as Dictionary<String,String>
        let response: String = userInfo["message"]!
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.resetButton.enabled = true
            self.boostButton.enabled = true
            self.noboostButton.enabled = true
            let alert = UIAlertController(title:  "SDA Response", message: response, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                
            }
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true) {
                
            }
        }
    }
    
    func gotHTMLResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<String,NSData> = notification.userInfo as Dictionary<String,NSData>
        let response: NSData = userInfo["data"]!
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.listButton.enabled = true
            self.pageRankButton.enabled = true
            if(self.webVC == nil) {
                self.webVC = WebViewController(nibName: "WebViewController", bundle: nil)
            }
            
            self.webVC.setViewData(response)
            if (self.navigationController?.topViewController.isKindOfClass(WebViewController) == nil)
            {
                self.navigationController?.pushViewController(self.webVC, animated: true)
            }
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
            self.resetButton.enabled = true
            self.boostButton.enabled = true
            self.noboostButton.enabled = true
            self.listButton.enabled = true
            self.presentViewController(alert, animated: true) {
                
            }
        }
        
    }
    
}
