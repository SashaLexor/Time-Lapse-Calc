//
//  Calculation+CoreDataProperties.swift
//  Time Lapse Calc
//
//  Created by 1024 on 26.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import Foundation
import CoreData
import MapKit

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
    @NSManaged public var photoID: NSNumber?
    
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
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoPath: String {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        let fullPhotoPath = (applicationDocumentsDirectory as NSString).appendingPathComponent(filename)
        print(fullPhotoPath)
        return fullPhotoPath
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        return fileURL
        
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
        
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: photoPath) {
                do {
                    try fileManager.removeItem(atPath: photoPath)
                } catch {
                    print("Error removing file: \(error)")
                }                
            }
        }
    }
   
    
}
