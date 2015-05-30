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
    
    var xocializeMe:Dictionary<String,String> = [:]
    
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var enableSwitch: UISwitch!
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var barCodeString: String = ""
    
    var barCodeType: String = ""
    
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
        
        println("Barcode: "+barCodeString)
        
        settings = dm.getSettings()
        
        println(settings)
        
        if barCodeString != "" {
            
            var myArray = barCodeString.componentsSeparatedByString("::")
            
            if myArray.count == 3 {
            
                if  myArray[0] as String == "xocialize_add_device" {
                    
                    println("Is a valid device add")
                    
                    enableSwitch.setOn(true, animated:false)
                    
                    processBarcode()
                
                } else {
                    
                    enableSwitch.setOn(false, animated:true)
                    
                    self.view.makeToast(message: "Scanned bar code is not a valid Xocialize add device bar code", duration: 5, position: HRToastPositionTop, title: "Bar Code Error")
                
                }
            } else {
            
                self.view.makeToast(message: "Scanned bar code is not a valid Xocialize add device bar code", duration: 5, position: HRToastPositionTop, title: "Bar Code Error")
            }
        }
        
        
        
        if let enabled = settings["xocializeEnabled"] as? Bool {
            
            enableSwitch.setOn(enabled, animated:true)
            
        } else {
            
            enableSwitch.setOn(false, animated:true)
            
        }
        
        enableSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    func post(params : Dictionary<String, String>, url : String) {
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        var err: NSError?
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            println("Body: \(strData)")
            
            var err: NSError?
            
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                
                println(err!.localizedDescription)
                
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                println("Error could not parse JSON: '\(jsonStr)'")
            } else {
                
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                
                if let parseJSON = json {
                    
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    
                    
                    
                    println("Succes: \(success)")
                    
                } else {
                    
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }

    func processBarcode(){
    
        if reachability.isReachable() {
            
            self.view.makeToast(message: "Starting Xocialize integration", duration: 2, position: HRToastPositionTop, title: "Adding")
            
            xocializeMe["barcode"] = barCodeString
            
            if let deviceUUID = settings["systemUUID"] as? String {
                
                xocializeMe["device_uuid"] = deviceUUID
            
                post(xocializeMe, url: "https://xocialize.com/add_device")
            
            } else {
            
                println(settings)
            
            }
        
        } else {
            
            self.view.makeToast(message: "Network Is Not Reachable", duration: 2, position: HRToastPositionTop, title: "Network Error")
        
        }
    
    }
    
    func stateChanged(switchState: UISwitch) {
        
        if enableSwitch.on {
            
            println("The Switch is On")
            
            if let xocializeId = settings["xocializeId"] as? String {
                
                settings["xocializeEnabled"] = true
            
                println(xocializeId)
            
            } else {
            
                performSegueWithIdentifier("xocializeToScannerSegue", sender: self)
            
            }
        
        } else {
        
            println("The Switch is Off")
            
            settings["xocializeEnabled"] = false
        
        }
        
        dm.saveSettings(settings)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if (segue.identifier == "xocializeToScannerSegue") {
            
            if let destinationVC = segue.destinationViewController as? Scanner{
                
                destinationVC.initiator = "xocialize"
                
            }
            
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
