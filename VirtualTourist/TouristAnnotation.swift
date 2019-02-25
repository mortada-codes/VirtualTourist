//
//  TouristAnnotation.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/18/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import Foundation
import MapKit

class TouristAnnotation :NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    
     init(coordinate coord:CLLocationCoordinate2D) {
       
        self.coordinate = coord
    }
    
    
}
