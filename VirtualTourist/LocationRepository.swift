//
//  LocationRepository.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/23/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import Foundation
import CoreData


class LocationRepository {
    
    let ENTITY_NAME = "CurrentLocation"
    let contextManager: NSManagedObjectContext
    let entity:NSEntityDescription
    var currentLocation:CurrentLocation?
    init(context:NSManagedObjectContext){
        self.contextManager = context
        self.entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: self.contextManager)!
        self.getLocation()
    }
    
    
    
    
    func setLocation(lat:Double,lon:Double,latDelta:Double,lonDelta:Double){
        if(currentLocation == nil){
            let currentLocation = CurrentLocation(context: contextManager)
        }
        
        if(currentLocation?.lat == lat && currentLocation?.lon == lon){
            return
        }
        currentLocation?.lat = lat
        currentLocation?.latDelta = latDelta
        currentLocation?.lon = lon
     currentLocation?.lonDelta = lonDelta
        do{
       try contextManager.save()
        }catch let error as NSError{
            print(error)
        }
    }
    
    func getLocation() -> CurrentLocation? {
        let fetchRequest = NSFetchRequest<CurrentLocation>(entityName: ENTITY_NAME)
        do{
        let result =   try contextManager.fetch(fetchRequest)
            if(result.isEmpty){
               print("empty")
                return nil
            
            }
          self.currentLocation = result.last
        
     return self.currentLocation
        } catch let error as NSError{
            print(error)
        }
        return nil
    }
    
    
}
