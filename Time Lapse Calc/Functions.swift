//
//  Functions.swift
//  Time Lapse Calc
//
//  Created by 1024 on 25.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, clouser: @escaping () -> ()) {
    let delay = DispatchTime.now().uptimeNanoseconds + UInt64(seconds * Double(NSEC_PER_SEC))
    let dispatchTimeDelay = DispatchTime(uptimeNanoseconds: delay)    
    DispatchQueue.main.asyncAfter(deadline: dispatchTimeDelay, execute: clouser)
}
