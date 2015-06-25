//
//  SettingsOrientationViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/27/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class SettingsOrientationViewController: UIViewController, UIPickerViewDelegate {
    
    var dm: DataManager = DataManager()
    
    var orientations = ["Auto","Landscape","Portrait"]
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    @IBOutlet var pickerView: UIPickerView!
    
    @IBAction func updateButton(sender: AnyObject) {
        
        if let selected = pickerView.selectedRowInComponent(0) as Int? {
            
            settings["orientation"] = selected
            
            dm.saveSettings(settings)
            
           performSegueWithIdentifier("OrientationSettingsToSettingsSegue", sender: self)
            
        }
        
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        performSegueWithIdentifier("OrientationSettingsToSettingsSegue", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        if let orientationInt = settings["orientation"] as? Int {
            
            pickerView.selectRow(orientationInt, inComponent: 0, animated: true)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return orientations.count
    }
    
    
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attributedString = NSAttributedString(string: orientations[row], attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        return attributedString
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
