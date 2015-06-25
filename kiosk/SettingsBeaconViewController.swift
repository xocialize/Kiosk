//
//  SettingsBeaconViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/28/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class SettingsBeaconViewController: UIViewController {
    
    var dm: DataManager = DataManager()
    
    var results:AnyObject?
    
    var settings:Dictionary<String,AnyObject> = [:]

    @IBOutlet var beaconUUID: UITextField!
    
    @IBOutlet var beaconMajor: UITextField!
    
    @IBOutlet var beaconMinor: UITextField!
    
    @IBOutlet var beaconEnabled: UISwitch!
    
    @IBAction func updateButton(sender: AnyObject) {
        
        var uuid = NSUUID(UUIDString: beaconUUID.text)
        
        var doSegue:Bool = true
        
        if uuid != nil {
            
            settings["iBeaconUUID"] = beaconUUID.text
            
            if Int(beaconMajor.text) < 65535 && Int(beaconMajor.text) > 0 {
            
                settings["iBeaconMajor"] = Int(beaconMajor.text)
                
            } else {
            
                doSegue = false
                
                beaconMajor.text = ""
                
                self.view.makeToast(message: "Beacon Major and Minor values need to be between 1 - 65535", duration: 10, position: HRToastPositionTop, title: "iBeacon Value Error")
            
            }
            
            if Int(beaconMinor.text) < 65535 && Int(beaconMinor.text) > 0 {
                
                settings["iBeaconMinor"] = Int(beaconMinor.text)
                
            } else {
                
                doSegue = false
                
                beaconMinor.text = ""
                
                self.view.makeToast(message: "Beacon Major and Minor values need to be between 1 - 65535", duration: 10, position: HRToastPositionTop, title: "iBeacon Value Error")
                
            }
            
            if beaconEnabled.on {
                
                settings["iBeaconEnabled"] = true
               
            
            } else {
            
                settings["iBeaconEnabled"] = false
                
            }
            
            dm.saveSettings(settings)
            
            if doSegue == true {
                
                performSegueWithIdentifier("BeaconSettingsToSettingsSegue", sender: self)
                
            }
        
        } else {
        
            self.view.makeToast(message: "The Beacon UUID you have entered is not valid.  Please enter a valid UUID", duration: 10, position: HRToastPositionTop, title: "iBeacon Value Error")
        }
        
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        performSegueWithIdentifier("BeaconSettingsToSettingsSegue", sender: self)
    
    }
    
    @IBAction func systemUUIDButton(sender: AnyObject) {
        
        if let UUID = settings["systemUUID"] as? String {
            
            beaconUUID.text = UUID
            
        } else {
        
            let uuid = NSUUID().UUIDString
            
            let uuidString = uuid as String
            
            settings["systemUUID"] = uuidString
            
            dm.saveSettings(settings)
            
            beaconUUID.text = uuidString
        
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        if let UUID = settings["iBeaconUUID"] as? String {
            
            beaconUUID.text = UUID
            
            print(UUID)
            
        }
        
        if let major = settings["iBeaconMajor"] as? Int {
            
            beaconMajor.text = "\(major)"
        
        }
        
        if let minor = settings["iBeaconMinor"] as? Int {
            
            beaconMinor.text = "\(minor)"
            
        }
        
        if let enabled = settings["iBeaconEnabled"] as? Bool {
            
            beaconEnabled.setOn(enabled, animated:true)
            
        } else {
            
            beaconEnabled.setOn(false, animated:true)
            
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
