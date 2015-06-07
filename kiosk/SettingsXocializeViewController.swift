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
    
    @IBOutlet var descriptionText: UITextField!
    
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
        
        if let value = descriptionText.text  {
            
            settings["xocializeDescription"] = value as String
            
        }
        
        dm.saveSettings(settings)
        
        performSegueWithIdentifier("xocializeToSettingsSegue", sender: self)
        
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
        
        if let descText = settings["xocializeDescription"] as? String {
        
            descriptionText.text = descText
        
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
            
            if(err != nil) {
                
                println(err!.localizedDescription)
                
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                println("Error could not parse JSON: '\(jsonStr)'")
            } else {
                
               if let parseJSON = json {
                    
                    if var success = parseJSON["success"] as? Int {
                        
                        if let authUUID = parseJSON["device_auth_uuid"] as? String {
                            
                            if var uuid = NSUUID(UUIDString: authUUID) {
                                
                                self.settings["auth_uuid"] = authUUID
                            
                            }
                            
                            if let accountId = parseJSON["accounts_id"] as? String {
                            
                                self.settings["accounts_id"] = accountId
                                
                            }
                            
                            if let messagesUrl = parseJSON["messages_url"] as? String {
                                
                                self.settings["messagesURL"] = messagesUrl
                                
                            }
                            
                            self.enableSwitch.setOn(true, animated:false)
                            
                            self.dm.saveSettings(self.settings)
                            
                        } else { println("couldn't decode device_auth_uuid") }
                    
                        println("Success: \(success)")
                        
                    }
                } else {
                    
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
            
                post(xocializeMe, url: "https://xocialize.com/device_manager")
            
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
            
            if let authUUID = settings["auth_uuid"] as? String {
                
                settings["xocializeEnabled"] = true
            
                println(authUUID)
            
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
    

   

}
