//
//  LocationManager.swift
//  CoreLocationSingletoneSwift
//
//  Created by Mikhail Pchelnikov on 08/11/14.
//  Copyright (c) 2014 Mikhail Pchelnikov. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class LocationManager: NSObject, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    class var shared : LocationManager {
        
        struct Static {
            static let instance : LocationManager = LocationManager()
        }
        
        return Static.instance
    }
    
    let locationManager = CLLocationManager()
    
    let geocoder = CLGeocoder()
    
    var currentLocation: CLLocation?
    
    var currentLocationText: String?
    
    var peripheralManager : CBPeripheralManager!
    
    var beaconData : NSDictionary!
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func authorize() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .AuthorizedAlways:
                    // Yes, always
                    println("LocationManager: Authorized")
                case .AuthorizedWhenInUse:
                    // Yes, only when our app is in use
                    println("LocationManager: Authorized")
                case .Denied:
                    // NO
                    displayAlertWithTitle("Not Determined", message: "Location services are not allowed for this app")
                case .NotDetermined:
                    // Ask for access
                    locationManager.requestWhenInUseAuthorization()
                case .Restricted:
                    // Have no access to location services
                    displayAlertWithTitle("Restricted", message: "Location services are not allowed for this app")
            }
        } else {
            displayAlertWithTitle("Not Enabled", message: "Location services are not enabled on this device")
        }
    }
    
    func displayAlertWithTitle(title: String, message: String) {
        
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func startUpdatingLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
        
            switch CLLocationManager.authorizationStatus() {
            
            case .AuthorizedAlways:
                    // Yes, always
                    locationManager.startUpdatingLocation()
            
            case .AuthorizedWhenInUse:
                    // Yes, only when our app is in use
                    locationManager.startUpdatingLocation()
            
            default:
                    println("Location Manager: Not started")
            }
        
        } else {
            // TODO: open preferences for app
            displayAlertWithTitle("Not Enabled", message: "Location services are not enabled on this device")
        }
    }
    
    func stopUpdatingLocation() {
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        locationManager.stopUpdatingLocation()
        
        if error != nil {
            println(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        currentLocation = locations.last as? CLLocation
        
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
            
                return println("Error: \(error)")
            
            } else {
            
                var placemark = placemarks.last as! CLPlacemark
                
                self.currentLocationText = placemark.thoroughfare

            }
        })
    }
    
    func iBeaconBroadcast(beaconId: NSUUID, major: Int = 1, minor: Int = 1) -> Bool {
        
        let beaconIdentifier = "kiosk"
        
        var majorValue = UInt16(major)
        
        var minorValue = UInt16(minor)
        
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconId, major: majorValue as CLBeaconMajorValue, minor: minorValue as CLBeaconMinorValue, identifier: beaconIdentifier)
        
        locationManager.delegate = self
        
        beaconData = beaconRegion.peripheralDataWithMeasuredPower(nil)
            
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
        return true
       
    }
    
    func iBeaconRange(beaconId: NSUUID, major: Int, minor: Int){
        
        let beaconIdentifier = "kiosk"
        
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconId, identifier: beaconIdentifier)
        
        locationManager.delegate = self
        
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startMonitoringForRegion(beaconRegion)
        
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        
        locationManager.startUpdatingLocation()
    
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        if(peripheral.state == CBPeripheralManagerState.PoweredOn) {
        
            println("powered on")
            self.peripheralManager.startAdvertising(beaconData as AnyObject as! [NSObject : AnyObject])
            
        } else if(peripheral.state == CBPeripheralManagerState.PoweredOff) {
            
            println("powered off")
            self.peripheralManager.stopAdvertising()
        
        } else {
        
            println("something else changed")
        
        }
    }
    
}