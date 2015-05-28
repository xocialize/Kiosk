//
//  SettingsXocializeViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 5/27/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class SettingsXocializeViewController: UIViewController {
    
    var dm: DataManager = DataManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var enableSwitch: UISwitch!
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        performSegueWithIdentifier("xocializeToSettingsSegue", sender: self)
        
    }
    
    @IBAction func updateButton(sender: AnyObject) {
        
        if enableSwitch.on {
            
            settings["xocializeEnabled"] = true
            
            
        } else {
            
            settings["xocializeEnabled"] = false
            
        }
        
        dm.saveSettings(settings)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settings = dm.getSettings()
        
        if let enabled = settings["xocializeEnabled"] as? Bool {
            
            enableSwitch.setOn(enabled, animated:true)
            
        } else {
            
            enableSwitch.setOn(false, animated:true)
            
        }
        
        enableSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func stateChanged(switchState: UISwitch) {
        
        if enableSwitch.on {
        
            println("The Switch is On")
        
        } else {
        
            println("The Switch is Off")
        
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        infoLabel.text = "Xocialize provides remote management for your Kiosk. \n\nIn order to add this device to Xocialize you will need a barcode generated at https://xocialize.com under the Kiosk > Devices section of the admin interface."
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
