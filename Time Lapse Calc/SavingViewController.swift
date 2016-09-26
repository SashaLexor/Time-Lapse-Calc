//
//  SavingViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 27.07.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

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
    var timer : Timer?
    var calc : TimeLapseCalc?
    var date = Date()
    var name = ""
    
    
    // MARK: - IBActions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        date = Date()
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.text = "Saved"
        
        afterDelay(0.6) { // realised in Functions.swift
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        // check the current authorization status
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization() // allows to get location updates while it is open and the user is interacting with it.
            return
        }
        
        // shows the alert if the authorization status is denied or restricted
        if authStatus == CLAuthorizationStatus.denied || authStatus == CLAuthorizationStatus.restricted {
            showLocationServicesDeniedAllert()
            return
        }
        
        startLocationManager()
        updateMap()
        hideGetLocationButtonAndShowMap()
    }
    
    
    
    // MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainInfoView.layer.cornerRadius = 8.0
        mainInfoView.clipsToBounds = true
        mainInfoView.layer.borderWidth = 1.0
        mainInfoView.layer.borderColor = UIColor.white.cgColor
        
        addPhotoView.layer.cornerRadius = 8.0
        addPhotoView.layer.borderWidth = 1.0
        addPhotoView.layer.borderColor = UIColor.white.cgColor
        addPhotoView.clipsToBounds = true
        
        mapViewContainer.layer.cornerRadius = 8.0
        mapViewContainer.layer.borderWidth = 1.0
        mapViewContainer.layer.borderColor = UIColor.white.cgColor
        mapViewContainer.clipsToBounds = true
        mapViewContainer.isHidden = true
        mapViewContainer.alpha = 0
        
        getLocationButton.layer.cornerRadius = 8.0
        getLocationButton.clipsToBounds = true
        
        for mainSubView in mainSubViews {
            mainSubView.layer.borderWidth = 0.5
            mainSubView.layer.borderColor = UIColor.white.cgColor
        }
        
        updateLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom methods
    func showLocationServicesDeniedAllert() {
        let allert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        allert.addAction(action)
        present(allert, animated: true, completion: nil)
    }
    
    func showLocationErrorAlertWhithMessage(_ message : String, andTitle title : String) {
        let allert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            self.hideGetLocationButtonAndShowMap()
        }
        allert.addAction(action)
        present(allert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let calc = calc {
            numberOfPhotosLabel.text = String(calc.numberOfPhotos)
            clipLengthLabel.text = String(format: "%02d", calc.clipLength.hours) + ":" + String(format: "%02d", calc.clipLength.minutes) + ":" + String(format: "%02d", calc.clipLength.seconds)
            fpsLabel.text = "\(calc.framesPerSecond)"
            shootingIntervalLabel.text = String(format: "%.2f", calc.shootingInterval)
            shootingDurationLabel.text = String(format: "%02d", calc.totalShootingDuration.hours) + ":" + String(format: "%02d", calc.totalShootingDuration.minutes) + ":" + String(format: "%02d", calc.totalShootingDuration.seconds)
            if calc.totalMemoryUsage < 1000 {
                memoryUsageLabel.text = String(calc.totalMemoryUsage) + " Mb"
            } else {
                memoryUsageLabel.text = String(Double(calc.totalMemoryUsage) / 1000.0) + " Gb"
            }
        }
    }
    
    func updateMap() {
        // TEMP DISPLAY
        if let location = location {
            print("Location is: \(location)")
        } else {
            let statusMessage : String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Code.denied.rawValue {
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
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.didTimeOut), userInfo: nil, repeats: false)
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
        UIView.animate(withDuration: 0.7, animations: {
            () -> Void in
            self.mapViewContainer.isHidden = !self.mapViewContainer.isHidden
            self.mapViewContainer.alpha = self.mapViewContainer.alpha == 1 ? 0 : 1
            self.getLocationButton.isHidden = !self.getLocationButton.isHidden
            self.getLocationButton.alpha = self.getLocationButton.alpha == 1 ? 0 : 1
        })
        
    }
    
}

// MARK: - CLLocationManagerDelegate

extension SavingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if error._code == CLError.Code.locationUnknown.rawValue {
            // The location is currently unknown, but Core Location will keep trying.
            return
        }
        lastLocationError = error as NSError?
        stopLocationManager()
        updateMap()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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


// MARK: - UITextFieldDelegate

extension SavingViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        name = textField.text!
        textField.resignFirstResponder()
        return true
    }
}

























