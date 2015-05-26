//
//  Scanner.swift
//  Kiosk
//
//  Created by Dustin Nielson on 3/13/15.
//  Copyright (c) 2015 Dustin Nielson. All rights reserved.
//

import UIKit
import AVFoundation

class Scanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let session = AVCaptureSession()
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var identifiedBorder : DiscoveredBarCodeView?
    
    var timer : NSTimer?
    
    @IBOutlet var scannerView: UIView!
    
    func addPreviewLayer() {
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        previewLayer?.bounds = self.view.bounds
        
        previewLayer?.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        
        scannerView.layer.addSublayer(previewLayer)
        
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            
            session.stopRunning()
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.hidden = false
        
        /*self.navigationItem.hidesBackButton = true
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        
        self.navigationItem.leftBarButtonItem = newBackButton;
        */
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        
        let inputDevice = AVCaptureDeviceInput(device: captureDevice, error: &error)
        
        if let inp = inputDevice {
        
            session.addInput(inp)
        
        } else {
        
            println(error)
        
        }
        
        addPreviewLayer()
        
        identifiedBorder = DiscoveredBarCodeView(frame: self.view.bounds)
        
        identifiedBorder?.backgroundColor = UIColor.clearColor()
        
        identifiedBorder?.hidden = true;
        
        self.view.addSubview(identifiedBorder!)
        
        
        /* Check for metadata */
        let output = AVCaptureMetadataOutput()
        
        session.addOutput(output)
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        //println(output.availableMetadataObjectTypes)
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        session.startRunning()
    }
    
    func back(sender: UIBarButtonItem){
        
        println("HERE");
        
        session.stopRunning()
        
        self.navigationController?.popViewControllerAnimated(true)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        session.startRunning()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        session.stopRunning()
    }
    
    func translatePoints(points : [AnyObject], fromView : UIView, toView: UIView) -> [CGPoint] {
        var translatedPoints : [CGPoint] = []
        for point in points {
            var dict = point as! NSDictionary
            let x = CGFloat((dict.objectForKey("X") as! NSNumber).floatValue)
            let y = CGFloat((dict.objectForKey("Y")as! NSNumber).floatValue)
            let curr = CGPointMake(x,y)
            let currFinal = fromView.convertPoint(curr, toView: toView)
            translatedPoints.append(currFinal)
        }
        return translatedPoints
    }
    
    func startTimer() {
        
       if timer?.valid != true {
        
            timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "removeBorder", userInfo: nil, repeats: false)
        
       } else {
        
            timer?.invalidate()
        
            self.removeBorder()
        
        }
    }
    
    func removeBorder() {
        /* Remove the identified border */
        self.identifiedBorder?.hidden = true
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for data in metadataObjects {
            let metaData = data as! AVMetadataObject
            
            println(metaData)
            
            if previewLayer != nil {
            
                let transformed: Optional = previewLayer?.transformedMetadataObjectForMetadataObject(metaData) as? AVMetadataMachineReadableCodeObject
                
                if let unwrapped = transformed {
                    identifiedBorder?.frame = unwrapped.bounds
                    identifiedBorder?.hidden = false
                    let identifiedCorners = self.translatePoints(unwrapped.corners, fromView: self.scannerView, toView: self.identifiedBorder!)
                    identifiedBorder?.drawBorder(identifiedCorners)
                    self.identifiedBorder?.hidden = false
                }
                self.startTimer()
            
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        //self.navigationController!.navigationBar.hidden = false
        
        self.title = "Scanner"
        
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if (segue.identifier == "toScannerSegue") {
            
            var svc = segue!.destinationViewController as! ViewController;
            
            //svc.toPass = "test"
            
            println("HERE")
            
        }
        
        if (segue.identifier == "scannerViewToMain") {
            
            var svc = segue!.destinationViewController as! ViewController;
            
            //svc.toPass = "test"
            
        }
    }
    
    func doSegue() {
        
        self.performSegueWithIdentifier("scannerViewToMain", sender: nil)
        
    }

}