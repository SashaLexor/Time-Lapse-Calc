//
//  SavingViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 27.07.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit

class SavingViewController: UIViewController {

   
    @IBOutlet weak var mainInfoView: UIView!
   // @IBOutlet var mainInfoSubViews: [UIView]!
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var getLocationButton: UIButton!
    
    @IBOutlet var mainSubViews: [UIView]!
    
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        
        getLocationButton.layer.cornerRadius = 8.0
        getLocationButton.clipsToBounds = true
        
        for mainSubView in mainSubViews {
            mainSubView.layer.borderWidth = 0.5
            mainSubView.layer.borderColor = UIColor.whiteColor().CGColor
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func save(sender: UIBarButtonItem) {
        UIView.animateWithDuration(0.5) {
            () -> Void in
            self.mapViewContainer.hidden = !self.mapViewContainer.hidden
            self.getLocationButton.hidden = !self.getLocationButton.hidden
        }
    }
    
    @IBAction func getLocation(sender: UIButton) {
        
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
