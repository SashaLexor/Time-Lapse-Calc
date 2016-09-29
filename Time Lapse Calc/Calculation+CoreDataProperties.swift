//
//  Calculation+CoreDataProperties.swift
//  Time Lapse Calc
//
//  Created by 1024 on 26.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import Foundation
import CoreData


extension Calculation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Calculation> {
        return NSFetchRequest<Calculation>(entityName: "Calculation");
    }

    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var date: NSDate
    @NSManaged public var name: String
    @NSManaged public var numberOfPhotos: Int64
    @NSManaged public var clipLengthHours: Int64
    @NSManaged public var clipLengthMinutes: Int64
    @NSManaged public var clipLengthSeconds: Int64
    @NSManaged public var fps: Double
    @NSManaged public var shootingInterval: Double
    @NSManaged public var shootingDurationHours: Int64
    @NSManaged public var shootingDurationMinutes: Int64
    @NSManaged public var shootingDurationSeconds: Int64
    @NSManaged public var memoryUsage: Int64
    
    var clipLength: Time {
        get {
            return Time(seconds: Int(clipLengthSeconds), minutes: Int(clipLengthMinutes), hours: Int(clipLengthHours))
        }
        set {
            self.clipLengthHours = Int64(newValue.hours)
            self.clipLengthMinutes = Int64(newValue.minutes)
            self.clipLengthSeconds = Int64(newValue.seconds)
        }
    }
    
    var shootingDuration: Time {
        get {
            return Time(seconds: Int(shootingDurationSeconds), minutes: Int(shootingDurationMinutes), hours: Int(shootingDurationHours))
        }
        set {
            self.shootingDurationHours = Int64(newValue.hours)
            self.shootingDurationMinutes = Int64(newValue.minutes)
            self.shootingDurationSeconds = Int64(newValue.seconds)
        }        
    }

}
