//
//  CustomAnnotation.swift
//  Time Lapse Calc
//
//  Created by 1024 on 30.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(whithLocation location: CLLocation, andTittle title: String?, andSubtitle subtitle: String?) {
        self.coordinate = location.coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
