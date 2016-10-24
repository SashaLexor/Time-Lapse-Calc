//
//  TimeLapseCalc.swift
//  Time Lapse Calculator
//
//  Created by 1024 on 19.03.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import Foundation


class TimeLapseCalc {
    
    var numberOfPhotos : Int = 0
    var clipLength = Time()
    var shootingInterval : Float = 0
    var framesPerSecond : Float = 24
    var imageSize : Float = 15.0
    var totalMemoryUsage : Float = 0
    var totalShootingDuration = Time()
    
    let fpsValues = [23.98, 24, 25, 30, 59.96, 60]
    var hoursArray : [Int] {
        var array = [Int]()
        for i in 0...24 {
            array.append(i)
        }
        return array
    }

    
    var minutesArray : [Int] {
        var array = [Int]()
        for i in 0...59 {
            array.append(i)
        }
        return array
    }
    
    var secondsArray : [Int] {
        var array = [Int]()
        for i in 0...59 {
            array.append(i)
        }
        return array
    }


    
    
    func calculateNumberOfPhotos() {
        numberOfPhotos = Int(Float(clipLength.totalTimeInSeconds) * framesPerSecond)
    }
    
    func calculateClipLength() {
        if framesPerSecond != 0 {
        clipLength.totalTimeInSeconds = Int(Float(numberOfPhotos) / framesPerSecond)
        }
    }
    
    func calculateShootingInterval() {
        if numberOfPhotos != 0 {
        shootingInterval = Float(totalShootingDuration.totalTimeInSeconds) / Float(numberOfPhotos)
        }
    }
    
    func calculateTotalMemoryUsage() {
        totalMemoryUsage = imageSize * Float(numberOfPhotos)
    }
    
    func calculateTotalMemoryUsageWith(_ singlePhotoSize: Float) {
        totalMemoryUsage = singlePhotoSize * Float(numberOfPhotos)
    }
    
    func calculateTotalShootingDuration() {
        totalShootingDuration.totalTimeInSeconds = Int(Float(numberOfPhotos) * shootingInterval)
    }
}

struct Time {
    var seconds = 0
    var minutes = 0
    var hours = 0
    
    var totalTimeInSeconds : Int {
        get {
            let time = hours * 3600 + minutes * 60 + seconds
            return time
        }
        set(newTime) {
            hours = Int(newTime/3600)
            minutes = Int((newTime - hours * 3600)/60)
            seconds = newTime - hours * 3600 - minutes * 60
        }
    }
    
}


