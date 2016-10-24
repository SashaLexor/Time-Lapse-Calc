//
//  CalculatorViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 21.07.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit
import CoreData


class CalculatorViewController: UIViewController {
    
    let calculator = TimeLapseCalc()
    let numberToolbar: UIToolbar = UIToolbar()
    var managedObjectContext: NSManagedObjectContext!
    var notificationObserver: AnyObject!
    let userDefaults = UserDefaults.standard
    var clipLenghtPriority: Bool?
    var shootingDurationPriority: Bool?
    var singlePhotoSize: Float?
    var defaultFpsIndex: Int?
    
    @IBOutlet weak var mainCalcView: UIView!
    @IBOutlet weak var numberOfPhotosTextField: UITextField!
    @IBOutlet weak var clipLenghtPicker: UIPickerView!
    @IBOutlet weak var fpsPicker: UIPickerView!
    @IBOutlet weak var shootingIntervalTextField: UITextField!
    @IBOutlet weak var totalShootingDurationPicker: UIPickerView!
    @IBOutlet weak var memoryUsageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet var smallViews: [UIView]!
    
    @IBAction func shareButtomTouchUp(_ sender: UIButton) {
        let date = Date()
        let dateStr = dateFormatter.string(from: date)
        let numberOfPhotos = String(calculator.numberOfPhotos)
        let clipLength = String(format: "%02d", calculator.clipLength.hours) + ":" + String(format: "%02d", calculator.clipLength.minutes) + ":" + String(format: "%02d", calculator.clipLength.seconds)
        let fps = String(calculator.framesPerSecond) + " fps"
        let shootingInterval = String(format: "%.02f", calculator.shootingInterval) + " sec."
        
        let shootingDuration = String(format: "%02d", calculator.totalShootingDuration.hours) + ":" + String(format: "%02d", calculator.totalShootingDuration.minutes) + ":" + String(format: "%02d", calculator.totalShootingDuration.seconds)
        
        var memoryUsage = ""
        if calculator.totalMemoryUsage < 1000 {
            memoryUsage = String(calculator.totalMemoryUsage) + " Mb"
        } else {
            memoryUsage = String(Double(calculator.totalMemoryUsage) / 1000.0) + " Gb"
        }
        
        
        let str = "Time Lapse Calculations\n\(dateStr)\n\nNumber of photos: \(numberOfPhotos)\nClip lenght: \(clipLength)\nFrames per second: \(fps)\nShooting interval: \(shootingInterval)\nShooting duration: \(shootingDuration)\nMemory usage: \(memoryUsage)"
        let activityViewController = UIActivityViewController(activityItems: [str], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCalcView.layer.cornerRadius = 8.0
        mainCalcView.clipsToBounds = true
        mainCalcView.layer.borderWidth = 1
        mainCalcView.layer.borderColor = UIColor.white.cgColor
        
        for smallView in smallViews {
            smallView.layer.borderWidth = 0.5
            smallView.layer.borderColor = UIColor.white.cgColor
        }
        
        shareButton.layer.cornerRadius = 8.0
        shareButton.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 8.0
        saveButton.clipsToBounds = true
        
        
        
        defaultFpsIndex = userDefaults.value(forKey: "defaultFpsIndex") as! Int?
        if defaultFpsIndex == nil {
            userDefaults.set(0, forKey: "defaultFpsIndex")
            defaultFpsIndex = 0
            
        }
        fpsPicker.selectRow(defaultFpsIndex!, inComponent: 0, animated: false)
        clipLenghtPicker.selectRow(480, inComponent: 0, animated: false)
        clipLenghtPicker.selectRow(480, inComponent: 1, animated: false)
        
        
        totalShootingDurationPicker.selectRow(500, inComponent: 0, animated: false)
        totalShootingDurationPicker.selectRow(480, inComponent: 1, animated: false)
        totalShootingDurationPicker.selectRow(480, inComponent: 2, animated: false)
        
        
        // Do any additional setup after loading the view.
        numberToolbar.barStyle = UIBarStyle.blackTranslucent
        numberToolbar.items=[UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                             UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CalculatorViewController.boopla))
        ]
        
        numberToolbar.sizeToFit()
        
        numberOfPhotosTextField.inputAccessoryView = numberToolbar //do it for every relevant textfield if there are more than one
        shootingIntervalTextField.inputAccessoryView = numberToolbar
        
        listenForBackgroundNotification()
        
    }
    
    deinit {
        print("Deinit CalculatorViewController")
        notificationObserver = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clipLenghtPriority = userDefaults.value(forKey: "clipLenghtPriority") as! Bool?
        if clipLenghtPriority == nil {
            userDefaults.set(true, forKey: "clipLenghtPriority")
            clipLenghtPriority = true
        }
        
        shootingDurationPriority = userDefaults.value(forKey: "shootingDurationPriority") as! Bool?
        if shootingDurationPriority == nil {
            userDefaults.set(true, forKey: "shootingDurationPriority")
            shootingDurationPriority = true
        }
        
        singlePhotoSize = userDefaults.value(forKey: "singlePhotoMemoryUsage") as! Float?
        if singlePhotoSize == nil {
            userDefaults.set(15.0, forKey: "singlePhotoMemoryUsage")
            singlePhotoSize = 15.0
        }
        
    }
    
    // MARK: CUSTOM functions
    
    func boopla () {
        numberOfPhotosTextField.resignFirstResponder()
        shootingIntervalTextField.resignFirstResponder()
    }
    
    func updateLabels() {
        numberOfPhotosTextField.text = String(calculator.numberOfPhotos)
        
        let minutesOnPiker = calculator.minutesArray[clipLenghtPicker.selectedRow(inComponent: 0) % calculator.minutesArray.count]
        let secondsOnPiker = calculator.secondsArray[clipLenghtPicker.selectedRow(inComponent: 1) % calculator.secondsArray.count]
        
        clipLenghtPicker.selectRow(480 + calculator.clipLength.minutes, inComponent: 0, animated: calculator.clipLength.minutes == minutesOnPiker ? false : true)
        clipLenghtPicker.selectRow(480 + calculator.clipLength.seconds, inComponent: 1, animated: calculator.clipLength.seconds == secondsOnPiker ? false : true)
        
        
        shootingIntervalTextField.text = String(format: "%.02f", calculator.shootingInterval)
        
        totalShootingDurationPicker.selectRow(500 + calculator.totalShootingDuration.hours, inComponent: 0, animated: false)
        totalShootingDurationPicker.selectRow(480 + calculator.totalShootingDuration.minutes, inComponent: 1, animated: false)
        totalShootingDurationPicker.selectRow(480 + calculator.totalShootingDuration.seconds, inComponent: 2, animated: false)
        
        if calculator.totalMemoryUsage < 1000 {
            memoryUsageLabel.text = String(calculator.totalMemoryUsage) + " Mb"
        } else {
            memoryUsageLabel.text = String(Double(calculator.totalMemoryUsage) / 1000.0) + " Gb"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveCalculations" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! SavingViewController
            controller.calc = calculator
            controller.managedObjectContext = managedObjectContext  // Send managedObjectContext to CalculatorViewController (from AppDelegate)
        }
    }
    
    
    func listenForBackgroundNotification() {
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) {
            [weak self] _ in
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                strongSelf.shootingIntervalTextField.resignFirstResponder()
                strongSelf.numberOfPhotosTextField.resignFirstResponder()
            }
        }
    }

}


extension CalculatorViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 {
            return 2
        } else if pickerView.tag == 2 {
            return 1
        } else if pickerView.tag == 3 {
            return 3
        } else {
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return 1000
        } else if pickerView.tag == 2 {
            return calculator.fpsValues.count
        } else if pickerView.tag == 3 {
            return 1000
        } else {
            return 0
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            pickerLabel?.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
        let titleData : String
        if pickerView.tag == 1 {
            if component == 0 {
                titleData = String(format: "%02d", calculator.minutesArray[row % calculator.minutesArray.count])
            } else if component == 1 {
                titleData = String(format: "%02d", calculator.secondsArray[row % calculator.secondsArray.count])
            } else {
                titleData = ""
            }
        } else if pickerView.tag == 2 {
            titleData = String(calculator.fpsValues[row % calculator.fpsValues.count])
        } else if pickerView.tag == 3 {
            if component == 0 {
                titleData = String(format: "%02d", calculator.hoursArray[row % calculator.hoursArray.count])
            } else if component == 1 {
                titleData = String(format: "%02d", calculator.minutesArray[row % calculator.minutesArray.count])
            } else if component == 2 {
                titleData = String(format: "%02d", calculator.secondsArray[row % calculator.secondsArray.count])
            }else {
                titleData = ""
            }
        } else {
            titleData = ""
        }
        
        let font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:font! ,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        pickerLabel?.layer.cornerRadius = 4.0
        pickerLabel?.clipsToBounds = true
        return pickerLabel!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Clip length picker
        if pickerView.tag == 1 {
            calculator.clipLength.hours = 0
            if component == 0 {
                calculator.clipLength.minutes = calculator.minutesArray[row % calculator.minutesArray.count]
            } else if component == 1 {
                calculator.clipLength.seconds = calculator.secondsArray[row % calculator.secondsArray.count]
            }
            calculator.calculateNumberOfPhotos()        // number
            if shootingDurationPriority! {
                calculator.calculateShootingInterval()      // interval
            } else {
                calculator.calculateTotalShootingDuration()
            }
            calculator.calculateTotalMemoryUsageWith(singlePhotoSize!)      // memory
        }
        // FPS picker
        if pickerView.tag == 2 {
            if component == 0 {
                calculator.framesPerSecond = Float(calculator.fpsValues[row])
                if clipLenghtPriority! {
                    calculator.calculateNumberOfPhotos()        // number
                } else {
                    calculator.calculateClipLength()
                }
                if shootingDurationPriority! {
                    calculator.calculateShootingInterval()      // interval
                } else {
                    calculator.calculateTotalShootingDuration()
                }
                
                calculator.calculateTotalMemoryUsageWith(singlePhotoSize!)       // memory
            }
        }
        // Shooting duration picker
        if pickerView.tag == 3 {
            if component == 0 {
                calculator.totalShootingDuration.hours = calculator.hoursArray[row % calculator.hoursArray.count]
            } else if component == 1 {
                calculator.totalShootingDuration.minutes = calculator.minutesArray[row % calculator.minutesArray.count]
            } else if component == 2 {
                calculator.totalShootingDuration.seconds = calculator.secondsArray[row % calculator.secondsArray.count]
            }
            calculator.calculateShootingInterval()
        }
        updateLabels()
    }

    
    
    // decimal input whit 1 dot || coma
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.components(separatedBy: ".").count)! > 1 && string == ".")
        {
            return false
        }
        if ((textField.text?.components(separatedBy: ",").count)! > 1 && string == ",")
        {
            return false
        }
        return string == "" || (string == "," || Float(string) != nil) || (string == "." || Float(string) != nil)
    }
    
    // read values from textFields
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Numer of photos textField
        if textField.tag == 4 {
            let str = textField.text
            if let numberOfPhotos = Int(str!){
                calculator.numberOfPhotos = numberOfPhotos
                calculator.calculateClipLength()            // length
                if shootingDurationPriority! {
                    calculator.calculateShootingInterval()      // interval
                } else {
                    calculator.calculateTotalShootingDuration()
                }
                calculator.calculateTotalMemoryUsageWith(singlePhotoSize!)       // memory
            }
        }
        // Shooting interval textField
        if textField.tag == 5 {
            let str = textField.text
            if let shootingInterval = Float(str!) {
                calculator.shootingInterval = shootingInterval
                calculator.calculateTotalShootingDuration() // duration
            }
        }
        updateLabels()
    }     
    
    
    
    
}


