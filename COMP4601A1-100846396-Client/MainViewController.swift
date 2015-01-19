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
    var viewAllVC: ViewAllViewController!
    
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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        if(self.viewAllVC == nil) {
            self.viewAllVC = ViewAllViewController(nibName: "ViewAllViewController", bundle: nil)
        }
        
        self.navigationController?.pushViewController(self.viewAllVC, animated: true)
    }

}
