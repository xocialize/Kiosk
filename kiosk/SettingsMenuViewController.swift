//
//  SettingsMenuViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/16/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class customEventCell: UITableViewCell {
    
    @IBOutlet var settingsImage: UIImageView!
    
    @IBOutlet var settingsLabel: UILabel!
    
}

class SettingsMenuViewController: UITableViewController {
    
    var dm = DataManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    var menuItems = ["GitHub Repository","Password","Orientation","iBeacon","Xocialize","Launch Kiosk"]
    
    var menuIcons = ["settings_github.png","settings_password.png","settings_orientation.png","settings_ibeacon.png","xocialize_120.png","settings_launch.png"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        /* Hide empty cells
        var tblView =  UIView(frame: CGRectZero)
        
        tableView.tableFooterView = tblView
        
        tableView.tableFooterView!.hidden = true
        
        tableView.backgroundColor = UIColor.clearColor()
        */
        
       
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        loadSetting(indexPath.row)
        
    }
    
    func loadSetting(settingItem: Int){
        
        switch settingItem {
        
        case 0:
            
            performSegueWithIdentifier("settingsToGitHubSegue", sender: self)
            
            break
            
        case 1:
            
            performSegueWithIdentifier("settingsToPasswordSettingsSegue", sender: self)
            
            break
            
        case 2:
            
            performSegueWithIdentifier("SettingsToOrientationSettingsSegue", sender: self)
            
            break
            
        case 3:
        
            performSegueWithIdentifier("settingsToBeaconSettingsSegue", sender: self)
            
            break
            
        case 4:
            
            performSegueWithIdentifier("settingsToXocializeSegue", sender: self)
            
            break
            
        case 5:
            
            prepareToLaunchKiosk()
            
            break
            
        default:
            
            print(settingItem)
        
        }
    
        
    
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100
        
    }
    
    func prepareToLaunchKiosk(){
    
        if dm.checkForIndex() {
        
            performSegueWithIdentifier("settingsToKioskSegue", sender: self)
        
        } else {
        
            self.view.makeToast(message: "No index.html file found", duration: 10, position: HRToastPositionTop, title: "Kiosk Launch Issue")
            
        }
        
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! customEventCell

        cell.settingsLabel.text = menuItems[indexPath.row]
        
        cell.settingsImage.image = UIImage(named:menuIcons[indexPath.row])

        return cell
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
