//
//  SettingsLoginViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/27/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class SettingsLoginViewController: UIViewController {

    @IBAction func loginButton(sender: AnyObject) {
        
        
        if passwordText.text == settings["password"] as? String {
        
            settingsToSettingsMenuSegue()
        
        } else {
        
            self.view.makeToast(message: "Invalid Password", duration: 3, position: HRToastPositionTop, title: "Authentication Error")
            
        }
    }
    
    @IBOutlet var passwordText: UITextField!
    
    var dm:DataManager = DataManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func settingsToSettingsMenuSegue(){
        
        self.performSegueWithIdentifier("loginToSettingsSegue", sender: self)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}
