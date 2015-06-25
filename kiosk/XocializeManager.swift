//
//  XocializeManager.swift
//  kiosk
//
//  Created by Dustin Nielson on 5/2/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import Foundation
import UIKit

class XocializeManager: NSObject {
    
    let dm: DataManager = DataManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    var queue:Dictionary<String,AnyObject> = [:]
    
    var ready:Bool = true
    
    // Mark JSON Utilities Author - Santosh Rajan
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        
        if NSJSONSerialization.isValidJSONObject(value) {
        
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
            
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                
                    return string as String
                
                }
            } catch _ {
            }
        }
        
        return ""
    }
    
    func JSONParseArray(jsonString: String) -> [AnyObject] {
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
        
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))  as? [AnyObject] {
            
                return array
            
            }
        }
        
        return [AnyObject]()
    }
    
    func JSONParseDictionary(jsonString: String) -> [String: AnyObject] {
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
        
            if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))  as? [String: AnyObject] {
                
                return dictionary
            
            }
        }
        
        return [String: AnyObject]()
    }
    
    func process(){
        
        settings = dm.getSettings()
        
        if var myurl = settings["messagesURL"] as? String, let accountsId = settings["accounts_id"] as? String, let authUUID = settings["auth_uuid"] as? String {
            
            myurl = "\(myurl)?accounts_id=\(accountsId)&auth_uuid=\(authUUID)"
        
            let url = NSURL(string: myurl)
            
            let session = NSURLSession.sharedSession()
            
            ready = false
        
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
                if let httpResponse = response as? NSHTTPURLResponse {
                
                    if let XRateLimit = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as? NSString {
                    
                        print("X-RateLimit-Remaining: \(XRateLimit)")
                    
                    }
                }
            
                if error != nil {
                
                    print(error)
                
                } else {
                
                    let jsonData: AnyObject = self.processJson(data)
                    
                    if let data = jsonData["success"] as? Int where data == 1 {
                        
                        if let messages = jsonData["messages"] as? NSArray {
                            
                            for message in messages {
                                
                                if let command = message["command"] as? String {
                                    
                                    switch(command){
                                    
                                        case "update_settings":
                                        
                                            if let messageData = message["data"] as? NSDictionary {
                                            
                                                self.updateSettings(messageData)
                                            
                                            }
                                        
                                        break
                                        
                                        default:
                                            print("Not a valid command")
                                        break
                                    
                                    }
                                
                                } else {
                                
                                    print("Not a valid message")
                                    
                                }
                            }
                            
                        } else {
                            
                            print("unable to convert messages")
                        
                            print(jsonData["messages"])
                        
                        }
                        
                    } else {
                    
                        print(jsonData)
                        
                    }
                    
                    //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    
                }
                
                self.ready = true
            })
        
            task.resume()
            
        } else { print("messages url not defined") }
    
    }
    
    func updateSettings(data: NSDictionary){
        
        settings = dm.getSettings()
        
        print(settings)
    
        for (key,value) in data {
            
            let keyText = "\(key)"
            
            switch(keyText){
            
                case "gitToken":
                
                    if let gitToken = data[keyText] as? String {
                    
                        settings["gitToken"] = gitToken
                    }
                    
                break;
                
                case "gitUser":
                
                    if let gitUser = data[keyText] as? String {
                    
                        settings["gitUser"] = gitUser
                    }
                
                break;
                
                case "gitRepo":
                
                    if let gitRepo = data[keyText] as? String {
                    
                        settings["gitRepo"] = gitRepo
                    }
                
                break;
                
                case "iBeaconEnabled":
                
                    if let iBeaconEnabled = data[keyText] as? Bool {
                    
                        settings["iBeaconEnabled"] = iBeaconEnabled
                    }
                
                break;
                
                case "iBeaconMajor":
                
                    if let iBeaconMajor = data[keyText] as? Int {
                    
                        settings["iBeaconMajor"] = iBeaconMajor
                    }
                
                break;
                
                case "iBeaconMinor":
                
                    if let iBeaconMinor = data[keyText] as? Int {
                    
                        settings["iBeaconMinor"] = iBeaconMinor
                    }
                
                break;
                
                case "iBeaconUUID":
                
                    if let iBeaconUUID = data[keyText] as? String {
                        
                        let uuid = NSUUID(UUIDString: iBeaconUUID)
                        
                        var doSegue:Bool = true
                        
                        if uuid != nil {
                            
                            settings["iBeaconUUID"] = iBeaconUUID
                        
                        }
                    }
                
                break;
                
                default:
                    
                    print("Not a valid setting")
                    
                    print("\(key) \(data[keyText])")
                
                break
            
            }
            
            
            
        }
        
        dm.saveSettings(settings)
        
    }
    
    func processJson(data: NSData) -> AnyObject {
        
        var jsonError: NSError?
        
        var completed: AnyObject?
        
        do {
            let jsonObject : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            
            if let directoryArray = jsonObject as? NSArray{
                
                completed = directoryArray as AnyObject
                
            } else if let directoryDictionary = jsonObject as? NSDictionary{
                
                completed = directoryDictionary as AnyObject
                
            }
            
        } catch let error as NSError {
            jsonError = error
            
            if let unwrappedError = jsonError {
                
                print("json error: \(unwrappedError)")
                
            }
        }
        
        return completed!
        
    }
    
    func settingsToXocialize(){
    
        settings = dm.getSettings()
        
        let settingsString = JSONStringify(settings, prettyPrinted: false)
        
        print("Settings: "+settingsString)
        
        if let deviceUUID: String = settings["systemUUID"] as? String,
            let authUUID: String = settings["auth_uuid"] as? String,
            let accountsId: String = settings["accounts_id"] as? String{
        
                var postme:Dictionary<String,String> = [:]
                
                postme["accounts_id"] = accountsId
                postme["auth_uuid"] = authUUID
                postme["device_uuid"] = deviceUUID
                postme["action"] = "updateDeviceSettings"
                postme["settings"] = settingsString
                
                post(postme, url:"https://xocialize.com/device_manager")
                

                
        } else {
        
            print("not ready to send settings")
        
        }
    
    }

    func post(params : Dictionary<String, String>, url : String) {
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        var err: NSError?
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch var error as NSError {
            err = error
            request.HTTPBody = nil
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        
            print("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            print("Body: \(strData)")
            
            var err: NSError?
            
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
            
                print(err!.localizedDescription)
                
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                print("Error could not parse JSON: '\(jsonStr)'")
            } else {
              
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                
                if let parseJSON = json {
                
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    
                    print("Succes: \(success)")
                
                } else {
                  
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    
                    print("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }
    
    
    
}
