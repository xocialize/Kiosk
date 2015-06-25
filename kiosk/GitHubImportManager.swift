//
//  GitHubImportManager.swift
//  kiosk
//
//  Created by Dustin Nielson on 5/4/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import Foundation

class GitHubImportManager: NSObject {
    
    var gitJson = [NSDictionary]()
    
    var dm = DataManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    var gitUser = ""
    
    var gitRepo = ""
    
    var gitToken = ""
    
    var filesCount = 0
    
    var working:Bool = false
    
    var gpErrorMsg:String = ""
    
    func beginImport(){
        
        working = true
        
        gpErrorMsg = ""
        
        settings = dm.getSettings()
        
        if let user = settings["gitUser"] as? String {
            
            gitUser = user
            
        }
        
        if let repo = settings["gitRepo"] as? String {
            
            gitRepo = repo
            
        }
        
       if let token = settings["gitToken"] as? String {
        
            gitToken = token
            
        }
        
        getContents("kiosk", stage: "check_kiosk")
        
    }
    
    func check_kiosk(jsonObject: AnyObject){
        
        if let objects = jsonObject as? NSDictionary {
            
            working = false
            
            if let message:String = objects["message"] as? String {
            
                gpErrorMsg = message
                
            
            } else {
            
                gpErrorMsg = "Unknown Error Encountered"
                
            }
            
        } else if let objects = jsonObject as? NSArray {
            
            dm.clearLibraryDirectory()
            
            for object in objects as NSArray{
                
                if let item:NSDictionary = object as? NSDictionary {
                    
                    if let type:String = item["type"] as? String{
                        
                        if type == "dir" {
                            
                            process_directory(jsonObject)
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func process_directory(jsonObject: AnyObject){
        
        if let objects = jsonObject as? NSArray {
            
            for object in objects as NSArray{
                
                if let item:NSDictionary = object as? NSDictionary {
                    
                    if let type:String = item["type"] as? String{
                        
                         if let path:String = item["path"] as? String{
                        
                            if type == "dir" {
                            
                                getContents(path, stage: "process_directory")
                                
                            } else if type == "file" {
                                
                                filesCount++
                            
                                getContents(path, stage: "process_file")
                            
                            }
                        }
                    }
                }
            }
        
        
        }
    
    }
    
    func process_file(jsonObject: AnyObject){
        
        if let objects = jsonObject as? NSDictionary {
            
            if let content:String = objects["content"] as? String {
                
                if let data = NSData(base64EncodedString: objects["content"] as! String, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                    
                    dm.saveToLibrary(data, path: objects["path"] as! String)
                    
                } else {
                    
                    if let download_url:String = objects["download_url"] as? String {
                        
                        let url = NSURL(string: download_url)
                        
                        let urlRequest = NSURLRequest(URL: url!)
                        
                        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                            response,data,error in
                            
                            if error != nil {
                                
                                print(error)
                                
                            } else {
                                
                                self.dm.saveToLibrary(data, path: objects["path"] as! String)
                                
                            }
                            
                        })
                        
                    }
                    
                    print("data decode failed.  manually downloaded.")
                    
                }
        
            }
        }
        
        filesCount--
        
        checkCompleted()
    
    }
    
    func checkCompleted(){
    
        if filesCount == 0 && working == true {
    
            working = false
            
        }
    
    }
    
    func getContents(path: String = "", stage: String = ""){
        
        var jsonObject: AnyObject?
        
        var urlPath: String = ""
        
        if gitToken != "" {
        
            urlPath = "https://api.github.com/repos/\(gitUser)/\(gitRepo)/contents/\(path)?access_token=\(gitToken)"
            
        } else {
        
            urlPath = "https://api.github.com/repos/\(gitUser)/\(gitRepo)/contents/\(path)"
        
        }
        
        print(urlPath)
        
        let url = NSURL(string: urlPath)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                
                if let XRateLimit = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as? NSString {
                    
                    print("X-RateLimit-Remaining: \(XRateLimit)")
                    
                }
            }
            
            if error != nil {
                
                print(error)
                
            } else {
                
                let jsonObject: AnyObject = self.processJson(data)
                
                switch stage {
                    
                case "check_kiosk":
                    
                    self.check_kiosk(jsonObject)
                    
                    break
                    
                case "process_directory":
                    
                    self.process_directory(jsonObject)
                    
                    break
                    
                case "process_file":
                    
                    self.process_file(jsonObject)
                    
                    break
                    
                default:
                        print(stage)
                    
                }
                
            
            }
        })
        
        task.resume()
        
    }
    
    func processJson(data: NSData) -> AnyObject {
        
        var jsonError: NSError?
        
        var completed: AnyObject?
        
        do {
            let jsonObject : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            
            if let directoryArray = jsonObject as? NSArray{
                
                completed = directoryArray as AnyObject
                
            } else if let directoryDictionary = jsonObject as? NSDictionary{
                
                if let message:String = directoryDictionary["message"] as? String {
                
                    gpErrorMsg = message
                
                }
                
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
    
    
    
}
