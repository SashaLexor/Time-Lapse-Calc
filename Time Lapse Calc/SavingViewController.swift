//
//  SavingViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 27.07.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Dispatch
import MapKit

class SavingViewController: UIViewController {
    
    // MARK: - Main views
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet var mainSubViews: [UIView]!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addPhotoImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    
    
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
    var date = Date()
    var image : UIImage?
    var managedObjectContext : NSManagedObjectContext!
    var notificationObserver: AnyObject!
    
    // Used for saving new calculation
    var calc : TimeLapseCalc? {
        didSet {
            if let calculator = calc {
                numberOfPhotos = calculator.numberOfPhotos
                clipLength = calculator.clipLength
                fps = Double(calculator.framesPerSecond)
                shootingInterval = Double(calculator.shootingInterval)
                shootingDuration = calculator.totalShootingDuration
                memoryUsage = calculator.totalMemoryUsage
            }
        }
    }
    
    // Used for edit saved calculation
    var calculationToEdit: Calculation? {
        didSet {
            if let calculation = calculationToEdit {
                name = calculation.name
                numberOfPhotos = Int(calculation.numberOfPhotos)
                clipLength = calculation.clipLength
                fps = calculation.fps
                shootingInterval = calculation.shootingInterval
                shootingDuration = calculation.shootingDuration
                memoryUsage = Int(calculation.memoryUsage)
                guard let latitude = calculation.latitude else {
                    print("calculation.latitude doesn't exist")
                    return
                }
                guard let longitude = calculation.longitude else {
                    print("calculation.longitude doesn't exist")
                    return
                }
                location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            }
        }
    }
    
    // Used for showing info in labels
    var name = ""
    var numberOfPhotos = 0
    var clipLength = Time()
    var fps = 0.0
    var shootingInterval = 0.0
    var shootingDuration = Time()
    var memoryUsage = 0
    
    
    // MARK: - IBActions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if updatingLocation {
            stopLocationManager()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        date = Date()
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        let calculation: Calculation
        if let tmp = calculationToEdit {
            hudView.text = "Updated"
            calculation = tmp
            
        } else {
            hudView.text = "Saved"
            calculation = NSEntityDescription.insertNewObject( forEntityName: "Calculation", into: managedObjectContext) as! Calculation
            calculation.photoID = nil
        }
        
        calculation.name = savingName.text!
        calculation.numberOfPhotos = Int64(numberOfPhotos)
        calculation.clipLength = clipLength
        calculation.fps = fps
        calculation.shootingInterval = shootingInterval
        calculation.shootingDuration = shootingDuration
        calculation.memoryUsage = Int64(memoryUsage)
        calculation.latitude = location?.coordinate.latitude as NSNumber?
        calculation.longitude = location?.coordinate.longitude as NSNumber?
        calculation.date = date as NSDate
        
        if let image = image {
            if !calculation.hasPhoto {
                calculation.photoID = Calculation.nextPhotoID() as NSNumber?
            }
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.write(to: calculation.photoURL, options: Data.WritingOptions.atomicWrite)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error: error)
        }
        
        /*
         afterDelay(0.6) { // Implemented in Functions.swift                     !!!! ERROR HERE TEST ON IPAD
         self.dismiss(animated: true, completion: nil)
         }
         */
        stopLocationManager()
        self.dismiss(animated: true, completion: nil)
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
        
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        startLocationManager()
        updateMap()
        hideGetLocationButtonAndShowMap()
    }
    
    
    @IBAction func addPhoto(_ sender: AnyObject) {
        pickPhoto()
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
        
        if let calculation = calculationToEdit {
            title = "Edit Calculation"
            if calculation.hasPhoto {
                if let image = calculation.photoImage {
                    showImage(image: image)
                }
            }
        }
        
        if let _ = location {
            hideGetLocationButtonAndShowMap()
        }
        
        listenForBackgroundNotification()
        updateMap()
        updateLabels()
        print(managedObjectContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(notificationObserver)
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
        savingName.text = name
        numberOfPhotosLabel.text = String(numberOfPhotos)
        clipLengthLabel.text = String(format: "%02d", clipLength.hours) + ":" + String(format: "%02d", clipLength.minutes) + ":" + String(format: "%02d", clipLength.seconds)
        fpsLabel.text = "\(fps)"
        shootingIntervalLabel.text = String(format: "%.2f", shootingInterval)
        shootingDurationLabel.text = String(format: "%02d", shootingDuration.hours) + ":" + String(format: "%02d", shootingDuration.minutes) + ":" + String(format: "%02d", shootingDuration.seconds)
        if memoryUsage < 1000 {
            memoryUsageLabel.text = String(memoryUsage) + " Mb"
        } else {
            memoryUsageLabel.text = String(Double(memoryUsage) / 1000.0) + " Gb"
        }
    }
    
    func updateMap() {
        
        if let location = location {
            print("Location is: \(location)")
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            let annotation = CustomAnnotation(whithLocation: location, andTittle: nil, andSubtitle: nil)
            mapView.addAnnotation(annotation)
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
            
            //messageLabelOnMap.text = statusMessage
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
    
    func listenForBackgroundNotification() {
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) {
            [weak self] _ in
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                strongSelf.savingName.resignFirstResponder()
            }
        }
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

// MARK: - MKMapViewDelegate

extension SavingViewController: MKMapViewDelegate { }


// MARK: - UIImagePickerControllerDelegate

extension SavingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        //present(imagePicker, animated: true, completion: nil)
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler:  {
            _ in
            self.takePhotoWithCamera()
        })
        let choosePhotoAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alertController.addAction(takePhotoAction)
        alertController.addAction(choosePhotoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showImage(image: UIImage) {
        addPhotoImageView.image = image
        visualEffectView.isHidden = true
        addPhotoButton.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = image {
            showImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}























