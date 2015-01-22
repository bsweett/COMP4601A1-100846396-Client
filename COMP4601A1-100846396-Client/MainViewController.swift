//
//  MainViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    
    var createVC: CreateViewController!
    var SearchVC: SearchViewController!
    var updateVC: UpdateViewController!
    var deleteVC: DeleteViewController!
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"VIEWALL", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func presentCreateView(sender: UIButton) {
        if(self.createVC == nil) {
            self.createVC = CreateViewController(nibName: "CreateViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.createVC, animated: true)
    }
    
    @IBAction func presentSearchView(sender: UIButton) {
        if(self.SearchVC == nil) {
            self.SearchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.SearchVC, animated: true)
    }
    
    @IBAction func presentUpdateView(sender: UIButton) {
        if(self.updateVC == nil) {
            self.updateVC = UpdateViewController(nibName: "UpdateViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.updateVC, animated: true)
    }
    
    @IBAction func presentDeleteView(sender: UIButton) {
        if(self.deleteVC == nil) {
            self.deleteVC = DeleteViewController(nibName: "DeleteViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.deleteVC, animated: true)
    }
    
    @IBAction func presentViewAllView(sender: UIButton) {
        
        viewAllButton.enabled = false
        SharedNetworkConnection.sharedInstance.viewAllDocumentsOnServer()
        
    }
    
    // MARK: - NSNotifications
    
    func gotResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<String,NSData> = notification.userInfo as Dictionary<String,NSData>
        let response: NSData = userInfo["data"]!
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.viewAllButton.enabled = true
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
            self.viewAllButton.enabled = true
            self.presentViewController(alert, animated: true) {
                
            }
        }
        
    }

}
