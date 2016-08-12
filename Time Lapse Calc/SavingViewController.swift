//
//  SavingViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 27.07.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit
import CoreLocation

class SavingViewController: UIViewController {
    
    // MARK: - Main views
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet var mainSubViews: [UIView]!
    
    // MARK: -  Info labels
    @IBOutlet weak var savingName: UITextField!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var clipLengthLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var shootingIntervalLabel: UILabel!
    @IBOutlet weak var shootingDurationLabel: UILabel!
    @IBOutlet weak var memoryUsageLabel: UILabel!
    @IBOutlet weak var messageLabelOnMap: UILabel!
    
    // MARK: -  Constants & Variables
    let locationManager = CLLocationManager()
    var location : CLLocation?
    var updatingLocation = false
    var lastLocationError : NSError?
    var timer : NSTimer?
    
    
    // MARK: - IBActions
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func getLocation(sender: UIButton) {
        // check the current authorization status
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization() // allows to get location updates while it is open and the user is interacting with it.
            return
        }
        
        // shows the alert if the authorization status is denied or restricted
        if authStatus == CLAuthorizationStatus.Denied || authStatus == CLAuthorizationStatus.Restricted {
            showLocationServicesDeniedAllert()
            return
        }
        
        startLocationManager()
        updateMap()
        hideGetLocationButtonAndShowMap()
        
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        UIView.animateWithDuration(0.5) {
            () -> Void in
            self.mapViewContainer.hidden = !self.mapViewContainer.hidden
            self.mapViewContainer.alpha = self.mapViewContainer.alpha == 1 ? 0 : 1
            self.getLocationButton.hidden = !self.getLocationButton.hidden
            self.getLocationButton.alpha = self.getLocationButton.alpha == 1 ? 0 : 1
        }
    }
    
    
    // MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainInfoView.layer.cornerRadius = 8.0
        mainInfoView.clipsToBounds = true
        mainInfoView.layer.borderWidth = 1.0
        mainInfoView.layer.borderColor = UIColor.whiteColor().CGColor
        
        addPhotoView.layer.cornerRadius = 8.0
        addPhotoView.layer.borderWidth = 1.0
        addPhotoView.layer.borderColor = UIColor.whiteColor().CGColor
        addPhotoView.clipsToBounds = true
        
        mapViewContainer.layer.cornerRadius = 8.0
        mapViewContainer.layer.borderWidth = 1.0
        mapViewContainer.layer.borderColor = UIColor.whiteColor().CGColor
        mapViewContainer.clipsToBounds = true
        mapViewContainer.hidden = true
        mapViewContainer.alpha = 0
        
        getLocationButton.layer.cornerRadius = 8.0
        getLocationButton.clipsToBounds = true
        
        for mainSubView in mainSubViews {
            mainSubView.layer.borderWidth = 0.5
            mainSubView.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom methods
    func showLocationServicesDeniedAllert() {
        let allert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        allert.addAction(action)
        presentViewController(allert, animated: true, completion: nil)
    }
    
    func showLocationErrorAlertWhithMessage(message : String, andTitle title : String) {
        let allert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            self.hideGetLocationButtonAndShowMap()
        }
        allert.addAction(action)
        presentViewController(allert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        
    }
    
    func updateMap() {
        // TEMP DISPLAY
        if let location = location {
            
        } else {
            numberOfPhotosLabel.text = ""
            clipLengthLabel.text = ""
            
            let statusMessage : String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                    showLocationErrorAlertWhithMessage("Please enable location services in options.", andTitle: statusMessage)
                } else {
                    statusMessage = "Error Getting Location"
                    showLocationErrorAlertWhithMessage("Please push 'Get location' button to try again", andTitle: statusMessage)
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get Location' to Start"
            }
            
            messageLabelOnMap.text = statusMessage
            
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // accuracy < 10m
            locationManager.startUpdatingLocation()
            updatingLocation = true
            lastLocationError = nil
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(self.didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func didTimeOut() {
        print("*** time out ***")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateMap()
        }
    }
    
    func hideGetLocationButtonAndShowMap() {
        UIView.animateWithDuration(0.7) {
            () -> Void in
            self.mapViewContainer.hidden = !self.mapViewContainer.hidden
            self.mapViewContainer.alpha = self.mapViewContainer.alpha == 1 ? 0 : 1
            self.getLocationButton.hidden = !self.getLocationButton.hidden
            self.getLocationButton.alpha = self.getLocationButton.alpha == 1 ? 0 : 1
        }
        
    }
    
}

// MARK: - CLLocationManagerDelegate

extension SavingViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            // The location is currently unknown, but Core Location will keep trying.
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateMap()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateMap()
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("We get location")
                let latitudeStr = String(format: "%.8f", location!.coordinate.latitude)
                let longitudeStr = String(format: "%.8f", location!.coordinate.longitude)
                messageLabelOnMap.text = "Latitude: \(latitudeStr)\nLogitude: \(longitudeStr)"
                stopLocationManager()
            }
        }
        
        updateMap()
    }
    
}




























