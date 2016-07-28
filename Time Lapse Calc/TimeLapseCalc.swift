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
    var imageSize : Int = 15
    var totalMemoryUsage : Int = 0
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


    
    
    func calculateNumberOfPhotos() -> Int {
        numberOfPhotos = Int(Float(clipLength.totalTimeInSeconds) * framesPerSecond)
        return numberOfPhotos
    }
    
    func calculateClipLength() -> Int {
        if framesPerSecond != 0 {
        clipLength.totalTimeInSeconds = Int(Float(numberOfPhotos) / framesPerSecond)
        return clipLength.totalTimeInSeconds
        } else {
            return -1
        }
    }
    
    func calculateShootingInterval() -> Float {
        if numberOfPhotos != 0 {
        shootingInterval = Float(totalShootingDuration.totalTimeInSeconds) / Float(numberOfPhotos)
        return shootingInterval
        } else {
            return -1
        }
    }
    
    func calculateTotalMemoryUsage() -> Int {
        totalMemoryUsage = imageSize * numberOfPhotos
        return totalMemoryUsage
    }
    
    func calculateTotalShootingDuration() -> Int {
        totalShootingDuration.totalTimeInSeconds = Int(Float(numberOfPhotos) * shootingInterval)
        return totalShootingDuration.totalTimeInSeconds
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


