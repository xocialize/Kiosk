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
    
    var barCodeString: String?
    
    var barCodeType: String?
    
    var initiator:String = ""
    
    var timer : NSTimer?
    
    @IBOutlet var cancelButton: UIButton!
    
    @IBAction func scannerCancelButton(sender: AnyObject) {
        
        if initiator == "xocialize" {
            
            session.stopRunning()
            
            performSegueWithIdentifier("scannerToXocializeSegue", sender: self)
            
        }
    }
    
    
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
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        
        let inputDevice = AVCaptureDeviceInput(device: captureDevice, error: &error)
        
        if let inp = inputDevice {
        
            session.addInput(inp)
        
        } else {
        
            println(error)
        
        }
        
        addPreviewLayer()
        
        self.view.autoresizesSubviews = true
        
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        
        self.view.bringSubviewToFront(cancelButton)
        
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
    
    override func shouldAutorotate() -> Bool{
        return true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        previewLayer?.bounds = self.view.bounds
        
        previewLayer?.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        
    }
    
    
    /*
    func deviceOrientationDidChange() {
        
        println("DEVICE ORIENTATION DID CHANGE CALLED")
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        
        //------ IGNORE THESE ORIENTATIONS ------
        if orientation == UIDeviceOrientation.FaceUp || orientation == UIDeviceOrientation.FaceDown || orientation == UIDeviceOrientation.Unknown || orientation == UIDeviceOrientation.PortraitUpsideDown || self.currentOrientation == orientation {
            println("device orientation is \(orientation) --- returning...")
            return
        }
        
        
        self.currentOrientation = orientation
        
        
        //------ APPLY A ROTATION USING THE STANDARD ROTATION TRANSFORMATION MATRIX in R3 ------
        /*
        
        x     y      z
        ---           ---
        x | cosø  -sinø   0 |
        y | sinø  cosø    0 |
        z | 0     0       1 |
        ---           ---
        
        BUT IMPLEMENTED BY APPLE AS
        
        x       y       z
        ---            ---
        x | cosø    sinø    0 |
        y | -sinø   consø   0 |
        z | 0       0       1 |
        ---            ---
        */
        
        //----- PERFORM VIDEO PREVIEW LAYER ROTATION BEFORE CAMERA CONTROLLER ROTATION ------
    
    switch orientation {
      
        case UIDeviceOrientation.Portrait:
            println("Device Orientation Portrait")
            if self.usingFrontCamera == true {
            }
            else {
                self.playBackTransformation = CGAffineTransformMakeRotation(self.degrees0)
                self.videoPreviewLayer?.setAffineTransform(self.playBackTransformation!)
                self.videoPreviewLayer!.frame = self.view.bounds
            }
            break
        case UIDeviceOrientation.LandscapeLeft:
            println("Device Orientation LandScapeLeft")
            if self.usingFrontCamera == true {
            }
            else {
                self.playBackTransformation = CGAffineTransformMakeRotation(CGFloat(-self.degrees90))
                self.videoPreviewLayer?.setAffineTransform(self.playBackTransformation!)
                self.videoPreviewLayer!.frame = self.view.bounds
            }
            break
        case UIDeviceOrientation.LandscapeRight:
            println("Device Orientation LandscapeRight")
            if self.usingFrontCamera == true {
            }
            else {
                self.playBackTransformation = CGAffineTransformMakeRotation(self.degrees90)
                self.videoPreviewLayer?.setAffineTransform(self.playBackTransformation!)
                self.videoPreviewLayer!.frame = self.view.bounds
            }
            break
        default:
            break
        }


    }
    */
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
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
        
        if metadataObjects.count > 0 {
        
            if let metaData = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                
                if previewLayer != nil {
                
                    if let testCodeType = metaData.valueForKey("type") as? String {
                    
                        barCodeType = testCodeType
                    }
                    
                    if let testCodeString = metaData.valueForKey("stringValue") as? String {
                        
                        barCodeString = testCodeString
                    }
                    
                    session.stopRunning()
                    
                    performSegueWithIdentifier("scannerToXocializeSegue", sender: self)
                }
            }
        }
        
        /*
        
        for data in metadataObjects {
            
            let metaData = data as! AVMetadataObject
            
            //println(metaData)
            
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
        */

    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if (segue.identifier == "scannerToXocializeSegue") {
            
            var destinationVC = segue!.destinationViewController as! SettingsXocializeViewController;
            
            if let bcString:String = barCodeString {
            
                destinationVC.barCodeString = barCodeString!
            
            }
            
            if let bcType:String = barCodeType {
            
                destinationVC.barCodeType = barCodeType!
                
            }
        }
    }
    
    

}