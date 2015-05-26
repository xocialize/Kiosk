//
//  ViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/13/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var dm: DataManager = DataManager()
    
    var timer = NSTimer()
    
    var settings: Dictionary<String,AnyObject> = [:]
    
    @IBAction func settingsLogin(sender: AnyObject) {
        
        launchSettings()
    
    }
    
    
    @IBAction func openSettingsButton(sender: AnyObject) {
        
        timer.invalidate()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        if settings.count > 0 {
            
            if dm.checkForIndex() {
            
                timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("mainToWebSegue"), userInfo: nil, repeats: false)
                
            } else {
            
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("launchSettings"), userInfo: nil, repeats: false)
            
            }
            
        } else {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("mainToSettingsDirect"), userInfo: nil, repeats: false)
            
        }
    }
    
    func launchSettings(){
    
        if let password = settings["password"] as? String {
            
            if password != "" {
                
                mainToLoginSegue()
                
            } else {
                
                mainToSettingsDirect()
                
            }
            
        } else {
            
            mainToSettingsDirect()
            
        }
    }
    
    func mainToWebSegue(){
        
        self.performSegueWithIdentifier("mainToWebSegue", sender: self)
        
    }
    
    func mainToLoginSegue(){
        
        self.performSegueWithIdentifier("mainToLoginSegue", sender: self)
        
    }
    
    func mainToSettingsDirect(){
        
        self.performSegueWithIdentifier("mainToSettingsDirect", sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

