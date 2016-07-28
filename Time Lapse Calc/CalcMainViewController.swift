//
//  CalcMainViewController.swift
//  Time Lapse Calculator
//
//  Created by 1024 on 21.03.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit

class CalcMainViewController: UIViewController {
    
    @IBOutlet weak var calculateSegmentControl: UISegmentedControl!
    
    var tableViewController : CalcTableViewController?
    var timeLapseCalc = TimeLapseCalc()

    @IBAction func selectCalculationsMode(sender: AnyObject) {
        print("selectCalculationsMode")
        if let tableView = tableViewController {
            tableView.calcMode = calculateSegmentControl.selectedSegmentIndex
            tableView.updateLabels()
        }
    }

    @IBAction func calculate(sender: AnyObject) {
        if let tableView = tableViewController {
            tableView.calculate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue")
        if segue.identifier == "CalcTableSegue" {
            tableViewController = segue.destinationViewController as? CalcTableViewController
            if let controller = tableViewController {
                controller.timeLapseCalc = timeLapseCalc
                controller.calcMode = calculateSegmentControl.selectedSegmentIndex
            }
        }
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
