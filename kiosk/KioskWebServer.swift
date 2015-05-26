//
//  KioskWebServer.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/13/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import Foundation

func KioskServer(publicDir: String?) -> HttpServer {
    
    var dm: DataManager = DataManager()
    
    let server = HttpServer()
    
    server["/"] = { request in
        
        var path = "kiosk\(request.url)"
        
        let newPath = path.stringByReplacingOccurrencesOfString("/", withString: "_")
        
        if path == "kiosk/ishere" {
        
            if let rootDir = publicDir {
            
                if let html = NSData(contentsOfFile:"\(rootDir)/index.html") {
                
                    return .RAW(200, html)
                
                } else {
                
                    return .NotFound
                }
            }
        
        } else {
            
            var folderPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
            
            let fileManager = NSFileManager.defaultManager()
            
            var filePath: String = ""
            
            if newPath == "kiosk_" {
            
                filePath  = "kiosk_index.html"
            
            } else {
            
                filePath = newPath
            
            }
            
            folderPath = folderPath + "/webFiles/" + filePath
            
            if NSFileManager.defaultManager().fileExistsAtPath(folderPath){
                
                var file:NSData = FileLoad.loadData(filePath, directory: NSSearchPathDirectory.LibraryDirectory, subdirectory: "webFiles")!
                
                return .RAW(200, file)
                
            } else {
                
                return .NotFound
                
            }
       }
        
        return .NotFound
    }
    
    
    return server
}