//
//  Functions.swift
//  Time Lapse Calc
//
//  Created by 1024 on 25.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import Foundation
import Dispatch
import CoreLocation
import MapKit

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

let applicationDocumentsDirectory: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    return paths[0] }()

func fatalCoreDataError(error: Error) {
    print("Core Data fatal error: \(error)")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
}

func afterDelay(_ seconds: Double, clouser: @escaping () -> ()) {
    let delay = DispatchTime.now().uptimeNanoseconds + UInt64(seconds * Double(NSEC_PER_SEC))
    let dispatchTimeDelay = DispatchTime(uptimeNanoseconds: delay)    
    DispatchQueue.main.asyncAfter(deadline: dispatchTimeDelay, execute: clouser)
}

