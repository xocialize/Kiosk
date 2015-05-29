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
