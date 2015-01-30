//
//  WebViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-21.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var viewData: NSData!
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - Lifecyle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedHelper.setNavBarForViewController(self, title: "Web View", withSubmitButton: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
    If HTML is found display it
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(self.viewData != nil) {
            webView.loadData(self.viewData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    Sets the data for display. Should be called before pushing view onto stack
    */
    func setViewData(data: NSData) {
        self.viewData = data
    }
}
