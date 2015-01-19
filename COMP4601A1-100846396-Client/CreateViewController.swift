//
//  CreateController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var documentField: UITextView!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var urlField: UITextView!
    @IBOutlet weak var addUrlButton: UIButton!
    
    weak var alert: UIAlertView!
    
    // MARK: - Lifecyle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedHelper.setNavBarForViewController(self, title: "Create Document", withSubmitButton: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
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
        
        if(self.alert == nil) {
            self.alert = UIAlertView()
        }
        self.alert.title = "Enter a URL"
        self.alert.message = "URL's are relative to: "
        self.alert.addButtonWithTitle("Done")
        self.alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        self.alert.addButtonWithTitle("Cancel")
        self.alert.show()
    }
    
    @IBAction func submitAction(sender: UIBarButtonItem) {
        
    }

}
