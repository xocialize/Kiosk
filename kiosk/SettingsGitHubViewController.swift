//
//  SettingsGitHubViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/28/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit

class SettingsGitHubViewController: UIViewController {

    var gp = GitHubImportManager()
    
    var dm = DataManager()
    
    var timer = NSTimer()
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var isReachable: Bool = false
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 150, 150))
    
    @IBOutlet var gitHubAccount: UITextField!
    
    @IBOutlet var gitHubRepoName: UITextField!
    
    @IBOutlet var gitHubToken: UITextField!
    
    @IBAction func updateGitHubButton(sender: AnyObject) {
        
        processGitHub()
        
    }
    
    @IBAction func cancelUpdateButton(sender: AnyObject) {
        
        self.performSegueWithIdentifier("gitHubToSettingsSegue", sender: self)
        
    }
    
    @IBAction func installDemoButton(sender: AnyObject) {
        
        gitHubRepoName.text = "Kiosk-Demo"
        
        gitHubAccount.text = "xocialize"
        
        processGitHub()
        
    }
    
    @IBAction func helpButton(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string:"http://xocialize.github.io/Kiosk/support.html")!)
        
    }
    
    
    var labelText = "NOTE: If you are recieving rate limit notices or things are not working please refer to http://xocialize.github.io/Kiosk/support.html"
    
    @IBOutlet var noteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        noteLabel.text = labelText
        
        if let gitUser = settings["gitUser"] as? String {
            
            gitHubAccount.text = gitUser
            
        }
        
        if let gitRepo = settings["gitRepo"] as? String {
            
            gitHubRepoName.text = gitRepo
            
        }
        
        if let gitToken = settings["gitToken"] as? String {
            
            gitHubToken.text = gitToken
            
        }
        
        reachability.whenReachable = { reachability in
            self.isReachable = true        }
        reachability.whenUnreachable = { reachability in
            self.isReachable = false
        }
        
        reachability.startNotifier()
        
        // Initial reachability check
        if reachability.isReachable() {
            isReachable=true
        } else {
            isReachable=false
        }
    }
    
    deinit {
        
        reachability.stopNotifier()
        
    }
    
    
    func processGitHub(){
        
        var user:String?
        
        var repo:String?
        
        self.view.makeToastActivity()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if let gitUser = gitHubAccount.text {
            
            settings["gitUser"] = gitUser
            
            user = gitUser
            
        }
        
        if let gitToken = gitHubToken.text {
            
            settings["gitToken"] = gitToken
            
        }
        
        if let gitRepo = gitHubRepoName.text {
            
            settings["gitRepo"] = gitRepo
            
            repo = gitRepo
            
        }
        
        dm.saveSettings(settings)
        
        if isReachable {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("finalizeProcessing"), userInfo: nil, repeats: false)
        
            gp.beginImport()
        
        } else {
        
            self.view.makeToast(message: "Network Is Not Reachable", duration: 2, position: HRToastPositionTop, title: "Network Error")
        
        }
        
        
    }
    
    func finalizeProcessing(){
    
        println(gp.working)
        
        if gp.working == true {
        
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("finalizeProcessing"), userInfo: nil, repeats: false)
        
        } else {
        
            println("Finished Processing")
            
            self.view.hideToastActivity()
            
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if gp.gpErrorMsg == "" {
            
                self.performSegueWithIdentifier("gitHubToSettingsSegue", sender: self)
                
            } else {
                
                self.view.makeToast(message: gp.gpErrorMsg, duration: 10, position: HRToastPositionTop, title: "Error durring import")
                
                gp.gpErrorMsg = ""
            
            }
            
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            isReachable=true
        } else {
            isReachable = false
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
