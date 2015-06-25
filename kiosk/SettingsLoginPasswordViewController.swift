//
//  SettingsLoginPasswordViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/28/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class SettingsLoginPasswordViewController: UIViewController {

    var dm: DataManager = DataManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var verifyPassword: UITextField!
    
    @IBAction func updatePasswordButton(sender: AnyObject) {
        
        if password.text == verifyPassword.text {
            
            if let value = password.text  {
                
                settings["password"] = value as String
                
                dm.saveSettings(settings)
               
            }
            
            performSegueWithIdentifier("passwordSettingsToSettingsSegue", sender: self)
            
        } else {
            
            let alertController = UIAlertController(title: "Password Error", message:
                "Passwords Do Not Match", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        performSegueWithIdentifier("passwordSettingsToSettingsSegue", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        if let passwordText = settings["password"] as? String {
            
            password.text = passwordText
            
            verifyPassword.text = passwordText
            
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
