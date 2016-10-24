//
//  OptionsViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 21.10.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var rateAppButton: UIButton!
    @IBOutlet var openWebSiteGesture: UITapGestureRecognizer!
    @IBOutlet weak var webSiteLabel: UILabel!
    @IBOutlet weak var singlePhotoSizeTextField: UITextField!
    @IBOutlet weak var defaultFpsPicker: UIPickerView!
    @IBOutlet weak var lenghtPrioritySwitch: UISwitch!
    @IBOutlet weak var shootingDurationPrioritySwitch: UISwitch!
    
    
    let userDefaults = UserDefaults.standard
    let numberToolbar: UIToolbar = UIToolbar()
    let fpsValues = [23.98, 24, 25, 30, 59.96, 60]

    @IBAction func rateApp(_ sender: UIButton) {
        let appID = "959379869"
        if let checkURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") {
            if UIApplication.shared.canOpenURL(checkURL) {
                print("url successfully opened")
                UIApplication.shared.openURL(checkURL)
            }
        } else {
            print("invalid url")
        }
    }
    
    @IBAction func setLenghtPriority(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "clipLenghtPriority")
    }
    
    
    @IBAction func setShootingDurtionPriority(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "shootingDurationPriority")
    }
    
    func openWebSite() {
        print("open web site")
        UIApplication.shared.openURL(URL(string: "http://lite-video.by/")!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "BG")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView
        
        
        iconImageView.layer.cornerRadius = 15.0
        iconImageView.clipsToBounds = true
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.white.cgColor
        
        rateAppButton.layer.cornerRadius = 8.0
        rateAppButton.clipsToBounds = true
        
        openWebSiteGesture.addTarget(self, action: #selector(self.openWebSite))
        webSiteLabel.addGestureRecognizer(openWebSiteGesture)
        
        if let lenghtPriority = userDefaults.value(forKey: "clipLenghtPriority") as! Bool? {
            lenghtPrioritySwitch.isOn = lenghtPriority
        }
        
        if let shootingDurationPriority = userDefaults.value(forKey: "shootingDurationPriority") as! Bool? {
            shootingDurationPrioritySwitch.isOn = shootingDurationPriority
        }
        
        if let singlePhotoSize = userDefaults.value(forKey: "singlePhotoMemoryUsage") as! Float? {
            singlePhotoSizeTextField.text = String(singlePhotoSize)
        }
        
        if let defaultFpsindex = userDefaults.value(forKey: "defaultFpsIndex") as! Int? {
            defaultFpsPicker.selectRow(defaultFpsindex, inComponent: 0, animated: false)
        }
        
        
        // Do any additional setup after loading the view.
        numberToolbar.barStyle = UIBarStyle.blackTranslucent
        numberToolbar.items=[UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                             UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(OptionsViewController.boopla))
        ]
        
        numberToolbar.sizeToFit()
        
        singlePhotoSizeTextField.inputAccessoryView = numberToolbar //do it for every relevant textfield if there are more than one
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Options View Controller Deinit")
    }
    
    func boopla () {
        singlePhotoSizeTextField.resignFirstResponder()
    }



}

extension OptionsViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: UItextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        let str = textField.text
        if let memoryUsage = Float(str!) {
            userDefaults.set(memoryUsage, forKey: "singlePhotoMemoryUsage")
        }
        
    }
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fpsValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            userDefaults.set(row, forKey: "defaultFpsIndex")
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
        
        titleData = String(fpsValues[row % fpsValues.count])        
        
        let font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:font! ,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        pickerLabel?.layer.cornerRadius = 4.0
        pickerLabel?.clipsToBounds = true
        return pickerLabel!
    }

    

    
    
    
}
