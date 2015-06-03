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
        
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
            
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                
                    return string as String
                
                }
            }
        }
        
        return ""
    }
    
    func JSONParseArray(jsonString: String) -> [AnyObject] {
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
        
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
            
                return array
            
            }
        }
        
        return [AnyObject]()
    }
    
    func JSONParseDictionary(jsonString: String) -> [String: AnyObject] {
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
        
            if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [String: AnyObject] {
                
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
                    
                        println("X-RateLimit-Remaining: \(XRateLimit)")
                    
                    }
                }
            
                if error != nil {
                
                    println(error)
                
                } else {
                
                    var jsonData: AnyObject = self.processJson(data)
                    
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
                                            println("Not a valid command")
                                        break
                                    
                                    }
                                
                                } else {
                                
                                    println("Not a valid message")
                                    
                                }
                            }
                            
                        } else {
                            
                            println("unable to convert messages")
                        
                            println(jsonData["messages"])
                        
                        }
                        
                    } else {
                    
                        println(jsonData)
                        
                    }
                    
                    //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    
                }
                
                self.ready = true
            })
        
            task.resume()
            
        } else { println("messages url not defined") }
    
    }
    
    func updateSettings(data: NSDictionary){
        
        settings = dm.getSettings()
        
        println(settings)
    
        for (key,value) in data {
            
            var keyText = "\(key)"
            
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
                        
                        var uuid = NSUUID(UUIDString: iBeaconUUID)
                        
                        var doSegue:Bool = true
                        
                        if uuid != nil {
                            
                            settings["iBeaconUUID"] = iBeaconUUID
                        
                        }
                    }
                
                break;
                
                default:
                    
                    println("Not a valid setting")
                    
                    println("\(key) \(data[keyText])")
                
                break
            
            }
            
            
            
        }
        
        dm.saveSettings(settings)
        
    }
    
    func processJson(data: NSData) -> AnyObject {
        
        var jsonError: NSError?
        
        var completed: AnyObject?
        
        if let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) {
            
            if let directoryArray = jsonObject as? NSArray{
                
                completed = directoryArray as AnyObject
                
            } else if let directoryDictionary = jsonObject as? NSDictionary{
                
                completed = directoryDictionary as AnyObject
                
            }
            
        } else {
            
            if let unwrappedError = jsonError {
                
                println("json error: \(unwrappedError)")
                
            }
        }
        
        return completed!
        
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
    
    
    
}
