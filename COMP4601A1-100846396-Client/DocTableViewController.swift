//
//  DocTableViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-24.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class DocTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var docList: Dictionary<Int,Document>! = Dictionary<Int, Document>()
    
    @IBOutlet weak var docTableView: UITableView!
    
    var webViewVC: WebViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"VIEW", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        
        SharedHelper.setNavBarForViewController(self, title: "Document Library", withSubmitButton: false)
        
        docTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    Finds a document id by a given name
    */
    private func findDocumentIdByName(dictionary: Dictionary<Int, Document>, text: String) -> Int {
        for elem in dictionary {
            if(elem.1.name == text) {
                return elem.1.id
            }
        }
        
        return 0
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.docList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "docCell")
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.textLabel?.textColor = UIColor.blackColor()
        
        var keys : [Int] = Array(self.docList.keys)
        
        if let doc = self.docList[keys[indexPath.row]]{
            let idAsString: String = String(doc.id)
            cell.textLabel?.text = (idAsString + " : " + doc.name)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.allowsSelection = false;
        
        let labelForRow = tableView.cellForRowAtIndexPath(indexPath)?.textLabel
        let idAsDisplay: [String] = (labelForRow?.text?.componentsSeparatedByString(" : "))!
        SharedNetworkConnection.sharedInstance.getDocumentOnServer(idAsDisplay[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
    }
    
    /**
    Sets the dictionary of documents that this table view holds. Should be called before pushing this
    view onto the stack
    */
    func setDocList(dictionary: Dictionary<Int, Document>) {
        self.docList = dictionary
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
            self.tableView.allowsSelection = true;
            
            if(self.webViewVC == nil) {
                self.webViewVC = WebViewController(nibName: "WebViewController", bundle: nil)
            }
            
            self.webViewVC.setViewData(response)
            self.navigationController?.pushViewController(self.webViewVC, animated: true)
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
            self.tableView.allowsSelection = true;
            self.presentViewController(alert, animated: true) {
                
            }
        }
    }
}
