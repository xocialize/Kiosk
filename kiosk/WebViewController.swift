//
//  WebViewController.swift
//  kiosk
//
//  Created by Dustin Nielson on 4/13/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit
import WebKit


class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    
    var theWebView:WKWebView?
    
    var timer = NSTimer()
    
    let dm: DataManager = DataManager()
    
    let lm: LocationManager = LocationManager()
    
    let xm: XocializeManager = XocializeManager()
    
    var settings:Dictionary<String,AnyObject> = [:]
    
    var barCodeString: String = ""
    
    var barCodeType: String = ""
    
    var orientation = 0
    
    var xocializeTimeInterval: NSTimeInterval = 30
    
    let url = NSURL(string: "http://localhost:8080")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = dm.getSettings()
        
        xm.settingsToXocialize()
        
        if settings["xocializeEnabled"] as? Bool == true {
            
            xocialize()
        }
        
        if settings["iBeaconEnabled"] as? Bool == true {
            
            startBeacon()
        }
        
        theWebView?.UIDelegate = self
        
        self.view.autoresizesSubviews = true
        
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        
        var contentController = WKUserContentController();
        
        var userScript = WKUserScript(
            source: "console.log(\"test\")",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        
        contentController.addUserScript(userScript)
        
        var theConfiguration = WKWebViewConfiguration()
        
        theConfiguration.userContentController = contentController
        
        theConfiguration.userContentController.addScriptMessageHandler(self,name: "interOp")
        
        theWebView = WKWebView(frame:self.view.frame, configuration: theConfiguration)
        
        theWebView!.scrollView.bounces=false
        
        theWebView!.scrollView.scrollEnabled=false
        
        view.backgroundColor = UIColor.redColor()
        
        theWebView!.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        theWebView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.view.addSubview(theWebView!)
        
       let req = NSURLRequest(URL: url!)
        
        theWebView!.loadRequest(req)
        
    }
    
    func xocialize(){
    
        if xm.ready { xm.process() }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(xocializeTimeInterval, target: self, selector: Selector("xocialize"), userInfo: nil, repeats: false)
        
    }
    
    func startBeacon(){
    
        var uuid = NSUUID(UUIDString: (settings["iBeaconUUID"] as? String)!)
        
        if uuid != nil {
            
            var beaconMajor = 1
            
            var beaconMinor = 1
            
            if let major:Int = settings["iBeaconMajor"] as? Int {
                
                beaconMajor = major
                
            }
            
            if let minor:Int = settings["iBeaconMinor"] as? Int {
                
                beaconMinor = minor
                
            }
            
            lm.iBeaconBroadcast(uuid!, major: beaconMajor, minor: beaconMinor)
            
        }
    
    }
    
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Send Image To Xocialize for processing
        
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if (segue.identifier == "webViewToScannerViewSegue") {
            
            if let destinationVC = segue.destinationViewController as? Scanner{
                
                destinationVC.initiator = "webView"
                
            }
            
        }
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage){
        
        println("got message: \(message.body)")
    
    }
    
    func sendToJS(){
    
        theWebView!.evaluateJavaScript("storeAndShow()", completionHandler: nil)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        if let orientationInt = settings["orientation"] as? Int {
            
            orientation = orientationInt
            
        }
        
        switch orientation {
        
        case 1:
            
            return Int(UIInterfaceOrientationMask.Landscape.rawValue)
            
        case 2:
            
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
            
        default:
            
            return (Int(UIInterfaceOrientationMask.All.rawValue))
        
        }
    }
    
    override func shouldAutorotate() -> Bool{
        return true
    }
    
    // MARK: WKUIDelegate methods
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (() -> Void)) {
        
        println("webView:\(webView) runJavaScriptAlertPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.URL!.host, message: message, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler()
            
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: ((Bool) -> Void)) {
        
        println("webView:\(webView) runJavaScriptConfirmPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.URL!.host, message: message, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            completionHandler(false)
        }))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler(true)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: ((String!) -> Void)) {
        
        println("webView:\(webView) runJavaScriptTextInputPanelWithPrompt:\(prompt) defaultText:\(defaultText) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.URL!.host, message: prompt, preferredStyle: .Alert)
        
        weak var alertTextField: UITextField!
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            completionHandler(nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}

