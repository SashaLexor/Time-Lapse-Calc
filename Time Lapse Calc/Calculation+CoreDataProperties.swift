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
    @NSManaged public var clipLength: Int64
    @NSManaged public var fps: Double
    @NSManaged public var shootingInterval: Double
    @NSManaged public var shootingDuration: Int64
    @NSManaged public var memoryUsage: Int64

}
