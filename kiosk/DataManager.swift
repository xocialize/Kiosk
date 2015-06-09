//
//  DataManager.swift
//  kiosk
//
//  Created by Dustin Nielson on 5/1/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataManager: NSObject, NSFileManagerDelegate {
    
    var appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //var xm: XocializeManager = XocializeManager()
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    // *** Mark Core Data Functions ***
    
    func getSettings() -> Dictionary<String,AnyObject> {
    
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Settings")
        
        request.returnsObjectsAsFaults = false
        
        var results = context.executeFetchRequest(request, error: nil)
        
        if results!.count > 0 {
            
            for result: AnyObject in results! {
                
                var xset = result.valueForKey("settingsData") as? NSData
                
               let settings:Dictionary<String,AnyObject> = NSKeyedUnarchiver.unarchiveObjectWithData(xset!)! as! Dictionary
                    
                return settings
            }
        } 
    
        return Dictionary<String,AnyObject>()
    
    }
    
    func checkForIndex() -> Bool{
    
        var folderPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
        
        let fileManager = NSFileManager.defaultManager()
        
        var filePath: String = "kiosk_index.html"
        
        folderPath = folderPath + "/webFiles/" + filePath
        
        if NSFileManager.defaultManager().fileExistsAtPath(folderPath){
            
            return true
            
        }
            
        return false
    
    }
    
    func saveSettings(dict: Dictionary<String,AnyObject> ){
        
        var settings:Dictionary<String,AnyObject> = dict
        
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Settings")
        
        request.returnsObjectsAsFaults = false
        
        var results = context.executeFetchRequest(request, error: nil)
        
        if results!.count > 0 {
            
            let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(settings)
            
            let settingsTest:Dictionary<String,AnyObject> = NSKeyedUnarchiver.unarchiveObjectWithData(data)! as! Dictionary
            
           for result: AnyObject in results! {
                
               result.setValue(data, forKey: "settingsData")
            
            }
            
        } else {
            
            var uuid = NSUUID().UUIDString
            
            var uuidString = uuid as String
            
            settings["systemUUID"] = uuidString
            
            let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(settings)
            
            var newPref = NSEntityDescription.insertNewObjectForEntityForName("Settings", inManagedObjectContext: context) as! NSManagedObject
            
            newPref.setValue(data, forKey: "settingsData")
        
        }
        
        context.save(nil)
        
        if settings["xocializeEnabled"] as? Bool == true {
            
            if reachability.isReachable() {
                
                var xm = XocializeManager()
                
                xm.settingsToXocialize()
            
            } else {
            
                println("Can't send settings to Xocialize")
            }
        }
    }
    
    // *** Mark File Directory Functions ***
    
    
    func showLibraryFiles(){
    
        var folderPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
        
        let fileManager = NSFileManager.defaultManager()
        
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(folderPath)!
        
        while let element = enumerator.nextObject() as? String {
            
            if element != "" {
                
                let filePath = folderPath + "/" + element
                println(filePath)
                
            }
        }
    
    }
    
    func clearLibraryDirectory(){
        
        var folderPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
        
        let fileManager = NSFileManager.defaultManager()
        
        folderPath = folderPath + "/webFiles"
        
        if NSFileManager.defaultManager().fileExistsAtPath(folderPath){
            
            fileManager.removeItemAtPath(folderPath, error: nil)
            
        }
        
    }
    
    func saveToLibrary(file:NSData, path:String){
    
        let newPath = path.stringByReplacingOccurrencesOfString("/", withString: "_")
        
        FileSave.saveData(file, directory:NSSearchPathDirectory.LibraryDirectory, path: newPath, subdirectory: "webFiles")
        
        var paths = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
        
        // Don't backup these files to iCloud
        
        var localUrl:NSURL = NSURL.fileURLWithPath(paths + "/webFiles/" + newPath)!
    
        var num:NSNumber = 1
        
        if localUrl.setResourceValue(num, forKey: "NSURLIsExcludedFromBackupKey", error: nil) {
        
            println("Backup Disabled")
            
        } else {
        
            println("Backup Enabled")
        
        }
        
    }
    
}
